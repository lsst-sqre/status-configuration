Terraform deployment
===

    cat > creds.sh <<END
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

    export TF_VAR_aws_access_key=$TF_VAR_aws_access_key
    export TF_VAR_aws_secret_key=$TF_VAR_aws_secret_key
    # defaults are for us-west-2; this is to use us-east-1
    export TF_VAR_aws_default_region=us-east-1
    export TF_VAR_status_ami=ami-6d1c2007
    END

    make
    . creds
    ./bin/terraform plan
    ./bin/terraform apply

    ssh -i id_rsa status-test.lsst.codes -l centos
