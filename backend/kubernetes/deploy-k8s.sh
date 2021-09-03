kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

kubectl apply -f namespace.yaml

kubectl apply -f booksService/deployment.yaml
kubectl apply -f booksService/service.yaml

kubectl apply -f usersService/deployment.yaml
kubectl apply -f usersService/service.yaml

kubectl apply -f promotionsService/deployment.yaml
kubectl apply -f promotionsService/service.yaml

kubectl apply -f recommendationsService/deployment.yaml
kubectl apply -f recommendationsService/service.yaml

kubectl apply -f ingress.yaml