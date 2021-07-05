echo -n "Please enter a lauch type of ECS (ec2 OR fargate): "
read lauch_type

if [ $lauch_type != "ec2" ] && [ $lauch_type != "fargate" ] && [ $lauch_type != "fargate_modules" ] && [ $lauch_type != "ec2_modules" ]; then
  echo "Select a valid lauch type of ECS"
  exit 0
fi

# Deploy books API docker image
cd ./services/booksService &&
./deploy_books_service.sh &&

# Deploy users API docker image
cd ../usersService &&
./deploy_users_service.sh &&

# Deploy recommendations API docker image
cd ../recommendationsService &&
./deploy_recommendations_service.sh &&

# Deploy to cloud host (default AWS)
if [ $lauch_type = "fargate" ]; then
  cd ../../devops/aws/ecs_fargate &&
  terraform apply
elif [ $lauch_type = "fargate_modules" ]; then
  cd ../../devops/aws/ecs_fargate_module &&
  terraform apply
elif [ $lauch_type = "ec2_modules" ]; then
  cd ../../devops/aws/ecs_ec2_module &&
  terraform apply
else
  cd ../../devops/aws/ecs_ec2 &&
  terraform apply
fi
