Cabinet Office Platform Engineering: Request an AWS Account
===============================================

User interface to request new AWS account within the Cabinet Office AWS organisation.

Running locally
---------------

This is a rails app, with dependencies managed by bundler. To run the app locally clone this repo, then:

```sh
bundle install
npm install
bundle exec rails server
```

If you want to test the apps interaction with third party services (e.g. GitHub
and GOV.UK Notify) you'll need to set up some secrets in environment variables.
The easiest way to do this in development is using a `.env` file (see [.env.example](.env.example)):

```sh
cp .env.example .env
$EDITOR .env
```

Run the tests with:

```sh
bundle exec rails test
```

To sign in as a development user, visit <http://localhost:3000/dev-login> (to try different email addresses, you can provide a `email` parameter). If you want to test with real Google SSO, you can [create an application in the Google Cloud Console](https://console.developers.google.com/apis/credentials).


Building Docker Image
--------------------

Note - when building the docker image on a mac arm but wanting to run the image on x86 architecture then run the `docker build` with this flag: `--platform="linux/amd64"`

Ruby App Master Key
-------------------

If running in production a master key is required to decrypt `credentials.yml.enc`. This has been created and is passed into the container/environment at runtime.


ENV vars
--------

  - `RAILS_ALLOWED_DOMAINS`: the domain of the app runtime env (eg localhost:3000 or sub.domain.tld)
  - `RAILS_SERVE_STATIC_FILES` true|false(default)
  - `RAILS_LOG_TO_STDOUT` true : will log out errors etc since production defaults to logfile
  - `RESTRICT_LOGIN_EMAIL_ADDRESSES_TO`: `example.one@digital.cabinet-office.gov.uk example.two@digital.cabinet-office.gov.uk` - should be a space separated list of email addresses if set it will only allow those email address to log in


ENV secrets
-----------

  - `GOOGLE_CLIENT_ID`: an OAuth2 client ID
  - `GOOGLE_CLIENT_SECRET`: an OAuth2 client secret
  - `GITHUB_PERSONAL_ACCESS_TOKEN`: the PAT required to act on requied cabinetoffice repos
  - `NOTIFY_API_KEY`: a key to use the notify api to send emails
  - `RAILS_MASTER_KEY`: the key that has been used to encode `config/credentials.yml.enc`

Updating the Cost Centre Information
-----------

We have a csv file in S3 which contains the Cabinet Office cost centre information. This is used to check the cost centre details entered by the user when requesting an AWS account. The original source for cost centre information in the intranet is updated monthly and we should replace the file in out S3 bucket periodically with the most up to date version.

You will need to be on the VPN both to access the file on the intranet, and to upload to to S3. 

Download the Cost Center Hierarchy CSV file available on [this Cabinet Office intranet page](https://intranet.cabinetoffice.gov.uk/managing-people-and-services/corporate-services-directory/cdt-information-hub/co-reporting/cabinet-office-cost-centres/).

Run the CSV Updater script from the root of the project with:
```sh
gds aws <account-name> -- bundle exec ruby bin/csv_updater -b "<bucket-name>" -f "<path-to-file>"
```
For test environment:
- Account name: ```co-aws-requests-app-staging```
- Bucket name: ```cope-request-aws-account-staging-csv```

Production environment:
- Account name: ```co-aws-requests-app-prod```
- Bucket name: ```cope-request-aws-account-prod-csv```

Path to file is the absolute path of the file eg: ```/Users/myusername/Downloads/cost_centres.csv```.

The script checks that the headers in the CSV have the expected values. If the upload fails because the headers have been changed, you need to update the keys accordingly in the ```mapping``` hash in the ```/bin/csv_updater``` file, leaving the values in the hash as they are (the examples shown in comments in the mapping give an idea of the format of the data in each column - this is to help identify which columns are needed if the headers have changed.)  

**Important note:** The csv file should not be made public, so if you save it inside the project, ensure you delete it after running the script and DO NOT push it to GitHub. 

**To apply the changes, you must restart the app.** 
Login to the AWS account by running: ```gds aws <account-name> -l```.
In the AWS console, open App Runner and click the orange deploy button to refresh the instance without downtime.
