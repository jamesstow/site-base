# site-base
nginx, php5 fpm, varnish in a docker container

You will need docker installed to run this

simply sun ./build.sh and it will create the site-base image for you locally

to test,run
```
docker run -tdi -p 80:80 site-base /sbin/my_init -- bash -l
```

When you want to include your stuff, mount the main html directory to /srv/www/public

eg
```
docker run -tdi -v /my_test_site_is_here:/srv/www/public -p 80:80 site-base /sbin/my_init -- bash -l
```

the files in src/varnish have been optimised for a simple wordpress site, if you need user logins or non caching of pages, then disable the varnish activation at

```
buid/etc/service/varnish/run
```

this is the file the init service watches, rename it anything other than "run" and varnish wont start.

Note: obviously this means you will have to dick around with your nginx config as its bound to port 8080 here
