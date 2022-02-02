echo "Please enter a lauch type of ECS (ec2 OR fargate OR eks OR lambda): "
read lauch_type

if [ $lauch_type != "ec2" ] && [ $lauch_type != "fargate" ] && [ $lauch_type != "eks" ] && [ $lauch_type != "lambda" ]; then
  echo "Select a valid lauch type of ECS"
  exit 0
fi

# Deploy to cloud host (default AWS)
if [ $lauch_type = "fargate" ]; then
  cd ./devops/aws/ecs_fargate &&
  terraform destroy
elif [ $lauch_type = "ec2" ]; then
  cd ./devops/aws/ecs_ec2 &&
  terraform destroy
elif [ $lauch_type = "eks" ]; then
  cd ./devops/aws/eks &&
  terraform destroy
else
  cd ./devops/aws/serverless &&
  terraform destroy
fi
