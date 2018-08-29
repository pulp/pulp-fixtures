About Cocktails and Boolean Dependencies
=========================================================

The goal is to relate the [boolean dependencies][1] to real-world objects
while also providing naturally-feeling testing data. The "top-level" packages
are various cocktails that, based on ones preferences/supplies, can be
adjusted while preparing. These adjustments are (hopefully) naturally
expressed thru the boolean dependencies within their package ``spec`` files.

Usage
------

Say you'd like to have a refreshing, citrussy and bitter tasting, Scotch-based
long drink. Assuming your repository contains the necessary ingredients and
your system is configured with the proper feed, you could query the repository
for just that:

```
$ dnf -b whatprovides citrussy bitter fruity Scotch long-drink
```

Ideally, your query result would look something like:

```
Cobbler-1-0.noarch : The Cobbler drink
Repo        : Cocktails
Matched from:
Provide    : citrussy
Provide    : long-drink
Provide    : fruity
Provide    : Scotch
Provide    : bitter

$ dnf info Cobbler
Last metadata expiration check: 5:01:52 ago on Tue Feb 27 12:31:28 2018.
Installed Packages
Name         : Cobbler
Version      : 1
Release      : 0
Arch         : noarch
Size         : 0.0
Source       : Cobbler-1-0.src.rpm
Repo         : @System
Summary      : The Cobbler drink
URL          : http://www.cocktails.in.th/whiskey.html
License      : 21+
Description  : A refreshing long drink that can be prepared in advance, so that the fruit can soak up some of the taste and alcohol.
             :
             : Put in a Balloon glass with some ice cubes:
             : - 8/10 Scotch
             : - 2/10 Contireau
             : - table spoon sugar
             :
             : Stir well and add bits of fresh fruit before serving
```

You'd be fine to take the ``Cobbler`` as is but in case you don't like stuff
floating in your drink, you might want to "install" it without pulling-in the
orange bits dependency:

```
$ sudo dnf --setopt=install_weak_dependencies=False --best instal Cobbler
```

If you prefer your bartender to select on your behalf:

```
$ sudo dnf --best install long-drink Scotch fruity
```

that should, thanks to the (weak) rich dependencies, result in getting
yourself a decent ``Cobbler`` drink too. Or, perhaps, you prefer fizzy:

```
$ sudo dnf --best install fizzy lemon long-drink
```

and to my best knowledge, you should be served a lovely ``PanAmerican`` drink

[1]: http://rpm.org/user_doc/boolean_dependencies.html

Thanks
-------

The automation bits are copied from `Ichimonji10 impedimenta <https://github.com/Ichimonji10/impedimenta/blob/master/bash/rpms/>`
