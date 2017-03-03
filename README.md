MySql backup to Amazon S3 - Automated
=================================

(This is not really an application, just a manual and some lines of code)

Amazon S3 can be an interestingly safe and cheap way to store your important data. Some of the most important data in the world is saved in... MySQL, and surely mine is quite important, so I needed such a script.

If you have a 500mb database (that's 10 times larger than any small site), with the priciest plan, keeping 6 backups (two months, two weeks, two days) costs $0.42 a month ($0.14GB/month). With 99.999999999% durability and 99.99% availability. Uploads are free, downloads would happen only in case you actually need to retrieve the backup (which hopefully won't be needed, but first GB is free, and over that $0.12/GB).

Even better: you get one free year up to 5GB storage and 15GB download. And, if you don't care about all the durability, later you can get the cheaper plan and spend $0.093GB/month.

The cons: you need to give them your credit card number. If you're like me, Amazon already has it anyway.

Another thing that is real nice: HTTPS connection and GPG encryption through s3cmd. Theorically it's safe enough.

Setup
-----

1. Register for Amazon AWS (yes, it asks for credit card).

2. Install s3cmd (following commands are for debian/ubuntu).
```
sudo apt-get update
sudo apt-get install s3cmd
```
3. Get your key and secret key in the IAM console [link](https://aws-portal.amazon.com/gp/aws/developer/account/index.html?ie=UTF8&action=access-key)

4. Go on your user folder.
```
cd /home/<YOURUSER>/
```

4. Configure s3cmd to work with your account.
```
s3cmd --configure
```
```
#The option are basically the following

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3
Access Key: xxxxxxxxxxxxxxxxxxxxxx
Secret Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password: xxxxxxxxxx
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP and can't be used if you're behind a proxy
Use HTTPS protocol [No]: Yes

New settings:
  Access Key: xxxxxxxxxxxxxxxxxxxxxx
  Secret Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  Encryption password: xxxxxxxxxx
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: True
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] Y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Success. Encryption and decryption worked fine :-)

Save settings? [y/N] y
Configuration saved to '/root/.s3cfg'
```

5. Make a bucket (must be an original name, s3cmd will tell you if it's already used).
```
s3cmd mb s3://my-database-backups
```

6. Now create the script in the folder `/home/<YOURUSER>/` with the command `sudo nano mysql-to-s3.sh` and copy and paste the code (or you can just upload the file that you find in this repository).

7. After do that config the script with the parameters of your database.

8. Give the file 755 permissions `chmod 755 /home/<YOURUSER>/mysql-to-s3.sh` or via FTP

9. Automated the process by typing in your shell `crontab -e` and paste this code:
```
# Run everday at 2am
0 2 * * * sudo bash /home/<YOURUSER>/mysql-to-s3.sh
```

Made with ❤️ by [nukleor](http://nukleor.com)
