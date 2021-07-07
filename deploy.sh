echo -n "Please enter a lauch type of ECS (ec2 OR fargate): "
read lauch_type

if [ $lauch_type != "ec2" ] && [ $lauch_type != "fargate" ]; then
  echo "Select a valid lauch type of ECS"
  exit 0
fi

# Deploy books API docker image
cd ./services/booksService &&
./deploy.sh &&

# Deploy users API docker image
cd ../usersService &&
./deploy.sh &&

# Deploy recommendations API docker image
cd ../recommendationsService &&
./deploy.sh &&

# Deploy promotions API docker image
cd ../promotionsService &&
./deploy.sh &&

# Deploy to cloud host (default AWS)
if [ $lauch_type = "fargate" ]; then
  cd ../../devops/aws/ecs_fargate_module &&
  terraform apply
else
  cd ../../devops/aws/ecs_ec2_module &&
  terraform apply
fi
