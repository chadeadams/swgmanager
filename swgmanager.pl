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
use IO::Handle;
use MIME::Base64;
use Socket;
use XML::LibXML;

#Autoflush On:
#$| = 1;
STDOUT->autoflush(1); # no need to mess with select()


#Setup Config Options a


#temp specificed options
our $dbname = "mysql";
our $mysql_server = "live.swgresurrection.com";
our $status_server = "live.swgresurrection.com";
our $mysql_port = "3306";
our $status_port = "44455";
our $mysql_username = "cadams";
our $mysql_password = "L0cktight4958";
our $servername = "SWG Resurrection";

our $dbh = "";

our $clear_screen = cls();

show_menu();





#Functions
sub show_menu {
  cls();
  print "        ================================================================\n";
  print "        |              Star Wars Galaxies Core3 Emulator               |\n";
  print "        |                      User/Account Manager                    |\n";
  print "        ================================================================\n";
  print "                          Server: " . $servername . "                       \n";
  my $numb_accounts = count_accounts();
  my $numb_characters = count_characters();
  print "              Number of accounts: " . $numb_accounts . "   Number of Characters: ". $numb_characters ."\n";
  print "\n\n";
  print "         General Information                       Server Actions \n";
  print "  ==================================   =====================================\n";
  print "   <S>... Search/View An Account         <SERVER>... Server Information\n";
  print "   <V>... View All Account                  <MON>... Monitor Server\n";
  print "   <A>... View Admin Accounts\n";
  print "   <I>... Accounts Info\n";
  print "   <H>... Help\n";
  print "\n\n";
  print "                           <Q>... Quit Program\n";
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
          case "S"  {show_account();}
          case "H"  {help();}
          case "V"  {show_all_accounts();}
          case "A"  {show_admin_accounts();}
          case "1"  {create_salt();}
          case "MON" {mon_server();}
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
  print "=============================================================\n";
  print "  Account Details for account: " . $username_given . "\n";
  print "=============================================================\n";
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
  print "Length of Salt: " . length($ref->{'salt'}) . "\n";
  #warn Dumper($ref);

  print "\n\n<S>...Show Characters on Account    <Q>.... Quit to Menu\n";
  print "Your command -> ";  my $choice = <STDIN>;
  chomp($choice);
  $choice = uc($choice);
  my $account_id = $ref->{'account_id'};

  switch ($choice) {
    case "S"  {show_characters($account_id);}
    case "Q"  {show_menu();}
    else {}

  }


  #print "\n\nPress any key to exit...\n"; <STDIN>;

}
  print "\n\n";
  disconnect_mysql();
  show_menu();

}

sub show_characters {
  my $passed_id = shift;
  my $character_select = $dbh->prepare("SELECT firstname, surname, creation_date FROM characters WHERE account_id = $passed_id");
  $character_select->execute();
  print "===========================================================\n";
  print "  Characters for account: \n";
  print "===========================================================\n";
  print "\n";
  print " First Name:                 Last Name:                 Date Created:\n";
  while (my $ref_char = $character_select->fetchrow_hashref()) {
      print "First Name: $ref_char->{'firstname'} Last Name: $ref_char->{'surname'} Created: $ref_char->{'creation_date'}\n";

  }

  print "Press any key to exit..." . <STDIN>;


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

sub count_admin_accounts {
connect_mysql();
my $sth = $dbh->prepare("SELECT * FROM accounts WHERE admin_level = '15'");
$sth->execute();
my $numb_admin_accounts = 0;
while (my $ref = $sth->fetchrow_hashref()) {
$numb_admin_accounts = $numb_admin_accounts + 1;
}
return $numb_admin_accounts;
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
  print "===============================================================================\n";
  print "Account Number(order)  Account Username:-> Account Creation Date\n";
  print "===============================================================================\n";
  my $count = 0;
  my $total_count = 0;
  while (my $ref = $sth->fetchrow_hashref()) {
    $count = $count + 1;
    $total_count = $total_count + 1;
    if ($count == 10){
      $count = 0;
      print "\n\n";
      print "Options: <ENTER>... Continue   <Q>... Quit To Menu\n";
      print "Please press a key -> ";
      my $answer = <STDIN>;
      print "\n";
      chomp($answer);
      $answer = uc($answer);
      switch ($answer){
          case ""  {}
          case "Q" {show_menu();}
          else {}
      }

    }
  my $username_clean = substr($ref->{'username'}, 0, 20);
     print "Number: $total_count  Username: " . $username_clean . " -> " . $ref->{'created'} . "\n";
  }
  print "\n";
  print "\n\nTotal number of accounts found and displayed: $total_count\n";
  print "===============================================================================\n";
  print "Press any key to exit... " . <STDIN>;
  disconnect_mysql();
  show_menu();
}

sub show_admin_accounts {
  my $numb_admin_accounts = count_admin_accounts();
  print "Total number of ADMIN accounts found: " . $numb_admin_accounts . "\n";
  connect_mysql();
  my $sth = $dbh->prepare("SELECT * FROM accounts WHERE admin_level=15");
  $sth->execute();
  my $count_shown = 0;
  print "===============================================================================\n";
  print "Account Number(order)  Account Username:-> Account Creation Date\n";
  print "===============================================================================\n";
  my $count = 0;
  my $total_count = 0;
  while (my $ref = $sth->fetchrow_hashref()) {
    $count = $count + 1;
    $total_count = $total_count + 1;
    if ($count == 10){
      $count = 0;
      print "\n\n";
      print "Options: <ENTER>... Continue   <Q>... Quit To Menu\n";
      print "Please press a key -> ";
      my $answer = <STDIN>;
      print "\n";
      chomp($answer);
      $answer = uc($answer);
      switch ($answer){
          case ""  {}
          case "Q" {show_menu();}
          else {}
      }

    }
  my $username_clean = substr($ref->{'username'}, 0, 20);
     print "Number: $total_count  Username: " . $username_clean . " -> " . $ref->{'created'} . "\n";
  }
  print "\n";
  print "\n\nTotal number of ADMIN accounts found and displayed: $total_count\n";
  print "===============================================================================\n";
  print "Press any key to exit... " . <STDIN>;
  disconnect_mysql();
  show_menu();

}


sub create_salt {

  my $count = 0;
  my $salt = "";
  my $max_salt = 15;
  while ($count < $max_salt) {
    my @char_list = split(//,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*?");
    $salt = $salt . @char_list[int(rand(scalar @char_list))];
    $count = $count + 1;
  }

  my $encoded_salt = encode_base64($salt);

  print "Salt = $salt\n";
  print "Length = " . length($salt) . "\n";
  print "Encoded Salt =" .  $encoded_salt . "\n";
  print "Length Encoded = " . length($encoded_salt);
  print "\n\n";
  print "Press any key to return to menu..." . <STDIN>;
  show_menu();
}

#Monitor Server Code

sub mon_server {
    socket(SOCKET, PF_INET, SOCK_STREAM, (getprotobyname('tcp'))[2]);
    connect( SOCKET, pack_sockaddr_in($status_port, inet_aton($status_server)));

    our $data_received = "";
    my $hold_data = "";
    while ($data_received=<SOCKET>) {
      $hold_data .= $data_received;
    }
    chomp($hold_data);
    #print "Data Receieved: " .  $hold_data . "\n";
    my $dom = XML::LibXML->load_xml(string => $hold_data);
    #print $hold_data;
    $dom->findnodes('/zoneServer/users/connected');
    my $users_connected_temp = $dom->to_literal();

    #Variables:
    my $extracted_servername = "";
    my $server_status = "";
    my $users_connected = "";
    my $total_max_users = "";
    my $uptime = "";
    my $time_pulled = "";

      #Put characters into an array
    my @info = split /\n/, $users_connected_temp;

    #assign Variables
   $extracted_servername = $info[1];
   $server_status = $info[2];
   $users_connected = $info[4];
   $total_max_users = $info[6];
   $uptime = $info[10];
   $time_pulled = $info[11];

   #Get uptime:
   my $sec = $uptime;

   #Convert status
   my $server_status_display = uc($server_status);

my $days = int($sec/(24*60*60));
my $hours = int($sec/(60*60)%24);
my $mins = int($sec/60)%60;
my $secs = int($sec%60);
my $uptime_display = "$days Days $hours Hours $mins Mins $secs Seconds";

#Set time pulled
my $time_pulled_display = scalar localtime( $time_pulled / 1000);
cls();

    #print status_port
    print "===========================================================================\n";
    print "|                          Server Status                                  |\n";
    print "===========================================================================\n";
    print "     Server: $extracted_servername @ " . $time_pulled_display . "\n";
    print "\n";
    print "                        SERVER STATUS: " . $server_status_display . "\n";
    print "                        Server Uptime: " . $uptime_display . "\n";
    print "                Total Users Connected: " . $users_connected . "\n";
    print "                  Max Number of Users: " . $total_max_users . "\n";
    print "\n\n";
    print "Press any key to exit...";
    <STDIN>;
}
