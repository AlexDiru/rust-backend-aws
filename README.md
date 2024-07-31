# rust-backend-aws

## Dockerise

```
docker build -t rust-backend-aws .
docker run -p 8000:8000 --rm rust-backend-aws
```

## Local TF

```
export AWS_PROFILE=iamadmin-general
terraform plan
terraform apply
```

# Make sure to add a new inbound rule to security group: 

- Type: All TCP
- Protocol: TCP
- Port Range: 0 - 65535
- Source: 0.0.0.0/0