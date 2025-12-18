-- Setup Snowflake Key-Pair Authentication for Hotel Personalization System
-- Execute this SQL in your Snowflake environment to configure the public key

-- Step 1: Add the RSA public key to your user account
-- Replace 'srsubramanian' with your actual username if different
ALTER USER srsubramanian SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5aWBAL/6wzdySoFf/G0EbjiSRstHQu7n6hkfkOS1JHzFnZoK+5Q92ViBQcXNfjmwtH3P2nn0NnI5RC8RIA0yRsuIHvnqta1yyp9FtnfFjFU6jdlzhR4Z0hNkbYLXs9pQeLKb8k2bf0r1z4H6yAOGZqdYg0L2BftQiMZDV46fNuhe/MsLrEM4uW2gZoOv4BLmbaWLUdn1aiUlp4WKx8myvfv2WDYwMQvWr6ERu7OSQ5w7gFW+b+PCyI2f/uVhRgFvixhNmynniAHHvp+d4HGv/wpU+AqTy6MhLCfyCDBew0IDi2vk0YO6cQrh2/nvGTElj1zhaaNySteK37xoYzqpNwIDAQAB';

-- Step 2: Verify the key was added successfully
DESC USER srsubramanian;

-- Step 3: Grant necessary permissions for the hotel personalization system
-- Create a role for hotel personalization if it doesn't exist
CREATE ROLE IF NOT EXISTS HOTEL_PERSONALIZATION_ADMIN;

-- Grant permissions to the role
GRANT CREATE DATABASE ON ACCOUNT TO ROLE HOTEL_PERSONALIZATION_ADMIN;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE HOTEL_PERSONALIZATION_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_PERSONALIZATION_ADMIN;

-- Grant the role to your user
GRANT ROLE HOTEL_PERSONALIZATION_ADMIN TO USER srsubramanian;

-- Set the role as default for this user (optional)
ALTER USER srsubramanian SET DEFAULT_ROLE = HOTEL_PERSONALIZATION_ADMIN;

-- Step 4: Verification queries
SELECT 'Key-pair authentication setup completed' as status;
SELECT CURRENT_USER() as current_user;
SELECT CURRENT_ROLE() as current_role;
SELECT CURRENT_WAREHOUSE() as current_warehouse;

-- Instructions for next steps
SELECT 'Next: Run python3 deploy_with_saved_auth.py to deploy the hotel personalization system' as next_step;




