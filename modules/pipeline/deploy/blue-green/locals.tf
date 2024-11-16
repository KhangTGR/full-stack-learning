locals {
  # Naming convention
  codedeploy_role_name        = "${var.prefix}-${var.environment}-codedeploy-role"
  deployment_group_name       = "${var.prefix}-${var.environment}-codedeploy-deployment-group"
  codedeploy_application_name = "${var.prefix}-${var.environment}-codedeploy-app"

  # appspec file
  appspec = {
    version = "0.0"
    Resources = [
      {
        TargetService = {
          Type = "AWS::ECS::Service"
          Properties = {
            TaskDefinition = "${var.ecs_task_def_arn}"
            LoadBalancerInfo = {
              ContainerName = "${var.container_name}"
              ContainerPort = "${var.container_port}"
            }
          }
        }
      }
    ]
  }
  appspec_content = replace(jsonencode(local.appspec), "\"", "\\\"")
  appspec_sha256  = sha256(jsonencode(local.appspec))

  # create deployment bash script
  script = <<EOF
#!/bin/bash

echo "creating deployment ..."
ID=$(aws deploy create-deployment \
    --application-name ${local.codedeploy_application_name} \
    --deployment-group-name ${local.deployment_group_name} \
    --revision '{"revisionType": "AppSpecContent", "appSpecContent": {"content": "${local.appspec_content}", "sha256": "${local.appspec_sha256}"}}' \
    --output text \
    --query '[deploymentId]')

echo "======================================================="
echo "waiting for deployment $deploymentId to finish ..."
STATUS=$(aws deploy get-deployment \
    --deployment-id $ID \
    --output text \
    --query '[deploymentInfo.status]')

while [[ $STATUS == "Created" || $STATUS == "InProgress" || $STATUS == "Pending" || $STATUS == "Queued" || $STATUS == "Ready" ]]; do
    echo "Status: $STATUS..."
    STATUS=$(aws deploy get-deployment \
        --deployment-id $ID \
        --output text \
        --query '[deploymentInfo.status]')

    SLEEP_TIME=30

    echo "Sleeping for: $SLEEP_TIME Seconds"
    sleep $SLEEP_TIME
done

if [[ $STATUS == "Succeeded" ]]; then
    echo "Deployment succeeded."
else
    echo "Deployment failed!"
    exit 1
fi

EOF

}

resource "local_file" "deploy_script" {
  filename             = "${path.module}/deploy_script.txt"
  directory_permission = "0755"
  file_permission      = "0644"
  content              = local.script

  depends_on = [
    aws_codedeploy_app.this,
    aws_codedeploy_deployment_group.this,
  ]
}

resource "null_resource" "start_deploy" {
  triggers = {
    appspec_sha256 = local.appspec_sha256 # run only if appspec file changed
  }

  provisioner "local-exec" {
    command     = local.script
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    aws_codedeploy_app.this,
    aws_codedeploy_deployment_group.this,
  ]
}
