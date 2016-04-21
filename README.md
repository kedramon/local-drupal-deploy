# local-drupal-deploy

edit default.conf for Your needs, it contain standart Apache config

***How-to***

execute:
```
sudo /bin/bush setup.sh
```

or make file executable:

```
chmod +x setup.sh

./filename.sh
```

Script will ask a **name** for folder and uses this name for configuration

Name can be passed as first param.

1) /var/www - location can be specified
2) apache config will be created based on default.conf
3) host will be added (127.0.0.1	**name**.local)
4) database can be created with db_name = db_user = db_pass = **name**
5) drush install from project