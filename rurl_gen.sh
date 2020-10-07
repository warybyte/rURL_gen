#!/bin/bash
#
# Random URL Generator for secure data transmission
#
# 0. Generate report data
# 1. Load report data into randomly generated page
# 2. Create password protected account to access client page
# 3. Transmit page link and credentials
# 4. Delete page and account when it is accessed                                    # Would require constant monitoring of access.log...
# 5. If page exists after 24 hours, delete it along with the account                # Cronjob could be dynamically updated with arbitrary time...
#
cuser="jsmith";                                                                     # This username is used for the login of the secured link
cpage=$(openssl rand -base64 2000 | tr -cd '[:alnum:]' | fold -w 10 | head -1);     # Random url generator
cpasswd=$(openssl rand -base64 2000 | tr -cd '[:alnum:]' | fold -w 10 | head -1);   # Pseudo-random password generator
cpath="/PATH/TO/FILE/$cpage.html";                                                  # Set path to to newly minted page
chown nginx:nginx $cpath;                                                           # Set ownership to whatever it needs to be
echo -e "$cpasswd" | sudo htpasswd -i -c /etc/nginx/.htpasswd-$cpage $cuser         # Set password/htpasswd file for user to access

sudo sed -i s/.htpasswd-client/.htpasswd-$cpage/g /etc/nginx/nginx.conf             # Using 'sed' to dynamically update my nginx.conf with
sudo sed -i s/client.html/$cpage.html/g /etc/nginx/nginx.conf                       # the new random links and password files
sudo service nginx restart                                                          # then restart Nginx

echo "<html>" >> $cpath                                                             # Now that the page is secured you can write whatever data
echo "Data insert after password..." >> $cpath                                      # needs to be written to it.
echo "</html>" >> $cpath

echo "Client page: https://itandme.org/client/$cpage.html";                         # Print data to screen so you can transmit out-of-band to 
echo "Username: $cuser;"                                                            # to whoever needs to access the page
echo "Client Password: $cpasswd";
ls /etc/nginx/.htpasswd-$cpage;

## FUTURE WORK... 
## Detect logging...needs to be written to a cron job that can continuously detect activity then act.
# grep "GET $cpath/$cpage" /var/log/nginx/access.log || echo "Status: Read" && echo "Status: Unread"

## Clean-up...needs to be written to a secondary script file to preserver environment values.
# sudo rm -rf $cpath;
# sudo sed -i s/.htpasswd-$cpage/.htpasswd-client/g /etc/nginx/nginx.conf
# sudo sed -i s/$cpage.html/client.html/g /etc/nginx/nginx.conf
