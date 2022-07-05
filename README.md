# What is this repository for? #
Collection of backend apps to simulate microservices ecosystem. We are using Terraform to deploy these microservices to AWS. Currently we support deploying using:
- ECS with Fargate
- ECS with EC2
- EKS
- Lambdas and API-Gateway for serverless flow

## Architecture Flow

Below we attach flow pipelines for the microservices:

### ECS
Cloud Architecture for ECS:
 <br />
 ![following](./static/ECS_Cloud_Architecture.jpg)

### EKS
Cloud Architecture for EKS:
 <br />
 ![following](./static/EKS_Cloud_Architecture.png)

### Serverless (API-Gateway and Lambdas)
Cloud Architecture for Serverless:
 <br />
 ![following](./static/Serverless_Cloud_Architecture.png)

### Deploy services: ###

In order to deploy microservices in AWS run the following cmd:

```shell
deploy.sh
```

and then specify the ECS deployment type, picking fargate or ec2.

### Destroy services: ###

In order to destroy clusters from AWS run the following cmd:

```shell
destroy.sh
```

## Endpoints

You can take a look at API's endpoints navigated to ${api_gateway_url} output from `deploy.sh` cmd.

### Collect transactions ###

```shell
POST ${api_gateway_url}/collector/transactions
```

Body Params:
```shell
{
    "records": [
        {

                "trxId": "004ed073-91b4-4623-ae33-7bef7cd104b0",
                "amount": 9000,
                "senderId": "2f9c0f77-623d-4c1f-af82-1148ee062c03",
                "receiverId": "340515af-476d-446b-bbdd-ad2b8585afd4",
                "senderIban": "GRxxxxxxxxxxxxxxx",
                "receiverIban": "BYxxxxxxxxxxxxxxxx",
                "senderBankId": "EUROBANK",
                "receiverBankId": "ALPHA",
                "transactionDate": "2022-06-30T07:41:46+0000"

        },
        {

                "trxId": "280eaebf-165e-42e0-9212-22df1127e84c",
                "amount": 333,
                "senderId": "2f9c0f77-623d-4c1f-af82-1148ee062c03",
                "receiverId": "340515af-476d-446b-bbdd-ad2b8585afd4",
                "senderIban": "GRxxxxxxxxxxxxxxx",
                "receiverIban": "BYxxxxxxxxxxxxxxxx",
                "senderBankId": "EUROBANK",
                "receiverBankId": "ALPHA",
                "transactionDate": "2022-06-30T07:41:46+0000"
            
        },
        {

                "trxId": "19754ab1-b19d-470b-be0e-4e1bf511761a",
                "amount": 300,
                "senderId": "2f9c0f77-623d-4c1f-af82-1148ee062c03",
                "receiverId": "340515af-476d-446b-bbdd-ad2b8585afd4",
                "senderIban": "GRxxxxxxxxxxxxxxx",
                "receiverIban": "BYxxxxxxxxxxxxxxxx",
                "senderBankId": "EUROBANK",
                "receiverBankId": "ALPHA",
                "transactionDate": "2022-06-30T07:41:46+0000"
        }
    ]
}
```

Description: adds new transactions records in Kinesis streams to be used and analyzed for anomaly_transactions_detector lambda

## Show your support

Give a ⭐️ if this project helped you!
