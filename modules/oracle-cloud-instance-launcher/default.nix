{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.lgoette.oracle-cloud-instance-launcher;
in
{
  options.lgoette.oracle-cloud-instance-launcher = {
    enable = mkEnableOption "Enable oracle-cloud script that launches an instance automatically if possible.";
  };

  config = mkIf cfg.enable {

    systemd.timers."oracle-cloud-instance-launcher" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "10m";
        Unit = "oracle-cloud-instance-launcher.service";
      };
    };

    systemd.services."oracle-cloud-instance-launcher" = {
      script = ''
        # Make shure, you have a "config" file and api-key certificate in /root/.oci/
        # Also be aware that the oci-cli package wants a .pub filetype as an ssh key file
        # Variables defined in /var/src/secrets/oracle/config.yaml

        COMPARTMENT_ID=$(${pkgs.yq}/bin/yq .COMPARTMENT_ID /var/src/secrets/oracle/config.yaml | xargs)
        SHAPE=$(${pkgs.yq}/bin/yq .SHAPE /var/src/secrets/oracle/config.yaml | xargs)
        SUBNET_ID=$(${pkgs.yq}/bin/yq .SUBNET_ID /var/src/secrets/oracle/config.yaml | xargs)
        DISPLAY_NAME=$(${pkgs.yq}/bin/yq .DISPLAY_NAME /var/src/secrets/oracle/config.yaml | xargs)
        IMAGE_ID=$(${pkgs.yq}/bin/yq .IMAGE_ID /var/src/secrets/oracle/config.yaml | xargs)
        SSH_KEYS_FILE=$(${pkgs.yq}/bin/yq .SSH_KEYS_FILE /var/src/secrets/oracle/config.yaml | xargs)
        # AVAILABILITY_DOMAINS # This Variable is used below


        # Function to launch instance
        launch_instance() {
            local availability_domain=$1
            output=$(${pkgs.oci-cli}/bin/oci compute instance launch \
                --availability-domain $availability_domain \
                --compartment-id $COMPARTMENT_ID \
                --shape $SHAPE \
                --subnet-id $SUBNET_ID \
                --assign-private-dns-record true \
                --assign-public-ip false \
                --availability-config "{\"recoveryAction\": \"RESTORE_INSTANCE\"}" \
                --display-name $DISPLAY_NAME \
                --image-id $IMAGE_ID \
                --boot-volume-size-in-gbs 200 \
                --instance-options "{\"areLegacyImdsEndpointsDisabled\": false}" \
                --shape-config "{\"ocpus\": 4, \"memoryInGBs\": 24}" \
                --ssh-authorized-keys-file $SSH_KEYS_FILE 2>&1)

            echo "$output" # Print the output (optional for debugging)
            return $? # Return the exit status
        }

        # Main logic
        output=$(${pkgs.oci-cli}/bin/oci compute instance list --compartment-id $COMPARTMENT_ID 2>&1)

        # Check if the output is empty or contains no instances
        if [[ -z "$output" || "$output" == *"\"data\": []"* ]]; then
            echo "No instances found in compartment $COMPARTMENT_ID."
        else
            echo "Instances found:"
            echo "$output"
            exit 1
        fi

        for domain in $(${pkgs.yq}/bin/yq -r '.AVAILABILITY_DOMAINS[]' /var/src/secrets/oracle/config.yaml | xargs); do
            echo "Trying to launch instance in availability domain: $domain"
            output=$(launch_instance "$domain")

            # Check if the output contains "Out of host capacity"
            if echo "$output" | grep -q '"message": "Out of host capacity.",'; then
                echo "Error: Out of host capacity. Retrying with the next availability domain..."
            else
                echo "Instance launched successfully!"
                echo $output
                exit 0
            fi
        done

        echo "Failed to launch instance in all specified availability domains."
        exit 1
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
