# -*- mode: perl; -*-
requires 'perl' => '5.20.0';
requires 'Mojolicious' => '8.23';
requires 'Role::Tiny' => '2.000001';

test_requires 'Test::More';

on develop => sub {
  requires 'Devel::Cover' => '1.33';
  requires "Pod::Coverage";
  requires 'App::git::ship' if $ENV{AUTHOR_RELEASE};
};
