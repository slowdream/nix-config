{
  lib,
  pkgs,
  ...
}:
{
  # https://developer.hashicorp.com/terraform/cli/config/config-file
  home.file.".terraformrc".source = ./terraformrc;

  home.packages = with pkgs; [
    # infrastructure as code
    # pulumi
    # pulumictl
    # tf2pulumi
    # crd2pulumi
    # pulumiPackages.pulumi-random
    # pulumiPackages.pulumi-command
    # pulumiPackages.pulumi-aws-native
    # pulumiPackages.pulumi-language-go
    # pulumiPackages.pulumi-language-python
    # pulumiPackages.pulumi-language-nodejs

    # AWS
    awscli2
    ssm-session-manager-plugin # плагин Amazon SSM Session Manager
    aws-iam-authenticator
    eksctl

    # Aliyun
    aliyun-cli
    # DigitalOcean
    doctl
    # Google Cloud
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))

    # облачные утилиты без кэша в binary cache nix
    terraform
    terraformer # terraform из существующих ресурсов
    packer # образы машин
  ];
}
