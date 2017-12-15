#!/usr/bin/perl

#=============================================================
#This program updates SWG Passwordds
#Author: nugax (nugax@thebytexchange.com)
#Date Started: 12/11/2017
#=============================================================

use strict;
use warnings;
use DBI;
use Switch;
use Term::ANSIScreen qw(cls);
use Config::Simple;
use Data::Dumper;

#Autoflush On:
$| = 1;

#Setup Config Options


#temp specificed options
our $dbname = "mysql";
our $mysql_server = "live.swgresurrection.com";
our $mysql_port = "3306";
our $mysql_username = "cadams";
our $mysql_password = "L0cktight4958";
our $servername = "SWG Resurrection";

our $dbh = "";

our $clear_screen = cls();

show_menu();





#Functions
sub show_menu {
  cls();
  print "================================================================\n";
  print "|              Star Wars Galaxies Core3 Emulator               |\n";
  print "|                      User/Account Manager                    |\n";
  print "================================================================\n";
  print "|                  Server: " . $servername . "                       \n";
  my $numb_accounts = count_accounts();
  my $numb_characters = count_characters();
  print "    Number of accounts: " . $numb_accounts . "   Number of Characters: ". $numb_characters ."\n";
  print "\n\n";
  print "                  <S>... Search For Account\n";
  print "                  <V>... View Account\n";
  print "                  <I>... Accounts Info\n";
  print "                  <A>... Show All Accounts\n";
  print "                  <H>... Help\n";
  print "\n\n";
  print "                  <Q>... Quit Program\n";
  print "\n\n";
  get_option();
}

sub get_option {
      print "Your choice: ";
      my $choice = <STDIN>;
      chomp($choice);
      $choice = uc($choice);

      switch($choice) {
          case "Q"  {exit;}
          case "V"  {show_account();}
          case "S"  {print "running s"; show_menu();}
          case "T"  {test();}
          case "H"  {help();}
          case "A"  {show_all_accounts();}
          else {show_menu();}
        }
}



sub execute {


}


sub connect_mysql {
    #Code to connect to mysql
    $dbh = DBI->connect("DBI:mysql:database=swgemu;host=live.swgresurrection.com",
                        "cadams", "L0cktight4958",
                        {'RaiseError' => 1});

}

sub disconnect_mysql {
    if ($dbh) {
       $dbh->disconnect();
       print "Database closed.\n";
    }

}

sub show_account {
  connect_mysql();
  my $username_given = "";
  print "\n";
  print "\nPlease enter Username: ";
  $username_given = <STDIN>;
  print "\n\n\n";
  chomp($username_given);
  my $sth = $dbh->prepare("SELECT * FROM accounts WHERE username = '$username_given' LIMIT 1");
  $sth->execute();
  #Pretty display
  print "======================================================\n";
  print "       Account Details for: " . $username_given . "\n";
  print "======================================================\n";
  print "\n";

  while (my $ref = $sth->fetchrow_hashref()) {
  #print "Found a row: Account ID: = $ref->{'id'}, name = $ref->{'username'}\n";
  print "Account ID: " . $ref->{'account_id'} . "\n";
  print "Username: " . $ref->{'username'} . "\n";
  print "Password: " . $ref->{'password'} . "\n";
  print "Station ID: " . $ref->{'station_id'} . "\n";
  print "Date Created: " . $ref->{'created'} . "\n";
  print "Active: " . $ref->{'active'} . "\n";
  print "Admin Level: " . $ref->{'admin_level'} . "\n";
  print "Salt: " . $ref->{'salt'} . "\n";
  #warn Dumper($ref);
  print "\n\nPress any key to exit...\n"; <STDIN>; 

}
  print "\n\n";
  disconnect_mysql();
  show_menu();

}




sub count_accounts {
connect_mysql();
my $sth = $dbh->prepare("SELECT * FROM accounts");
$sth->execute();
my $numb_accounts = 0;
while (my $ref = $sth->fetchrow_hashref()) {
$numb_accounts = $numb_accounts + 1;
}
return $numb_accounts;
disconnect_mysql();
}

sub count_characters {
  connect_mysql();
  my $sth = $dbh->prepare("SELECT * FROM characters");
  $sth->execute();
  my $numb_characters = 0;
  while (my $ref = $sth->fetchrow_hashref()) {
  $numb_characters = $numb_characters + 1;
  }
  return $numb_characters;
  disconnect_mysql();
}

sub show_all_accounts {
  my $numb_accounts = count_accounts();
  print "Total number of accounts found: " . $numb_accounts . "\n";
  connect_mysql();
  my $sth = $dbh->prepare("SELECT * FROM accounts");
  $sth->execute();
  my $count_shown = 0;
  print "============================================================\n";
  my $count = 0;
  my $total_count = 0;
  while (my $ref = $sth->fetchrow_hashref()) {
    $count = $count + 1;
    $total_count = $total_count + 1;
    if ($count == 10){
      $count = 0;
      print "Press any key...\n";  <STDIN>;
    }

   print "Number: $total_count  Username: " . $ref->{'username'} . "  Date Created: " . $ref->{'created'} . "\n";
  }
  print "\n\nTotal number of accounts found and displayed: $total_count\n";
  print "=============================================================\n\n";
  print "Press any key to exit... " . <STDIN>;
  disconnect_mysql();
  show_menu();
}
