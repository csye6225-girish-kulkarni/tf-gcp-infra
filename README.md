# tf-gcp-infra


Commands Used to Create terraform files : 

``` 
terraform init 
terraform validate
terraform plan 
terraform apply -var="project=my-gcp-project" -var="region=us-east1"
```



The GCP API Needed to use this is :

https://console.cloud.google.com/apis/library/vpcaccess.googleapis.com?hl=en&project=cloud-vpc-terraform