#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use JSON::PP;
use HTTP::Tiny;
use Path::Tiny;
use Data::Dumper;
use JSON::Validator;

use Utils;

sub get_input_data {
    my ($input_file_name) = @_;

    die "No file $input_file_name" if not -e $input_file_name;

    my $input_content = path($input_file_name)->slurp();
    my $input_data = {};

    eval {
        $input_data = decode_json $input_content;
    };

    if ($@) {
        die "Can't parse json from $input_file_name";
    }

    my $jv = JSON::Validator->new();
    $jv->schema('file:///app/data/input_schema.json');
    my @errors = $jv->validate($input_data);

    if (@errors) {
        die "Content of file $input_file_name does not match schema:\n@errors";
    }

    return $input_data;
}

sub login {
    my (%h) = @_;

    my $login = delete $h{login};
    die 'no login' if not defined $login;

    my $password = delete $h{password};
    die 'no password' if not defined $password;

    die if %h;

    my $response = HTTP::Tiny->new()->request(
        'POST',
        'http://stat.knetwork.ru/customer_api/login',
        {
            headers => {
                'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
                'Accept' => 'application/json, text/plain, */*',
                'Accept-Language' => 'en-US,en;q=0.9',
                'Cache-Control' => 'no-cache',
                'Connection' => 'keep-alive',
                'Content-Type' => 'application/json;charset=UTF-8',
                'Origin' => 'http://stat.knetwork.ru',
                'Pragma' => 'no-cache',
                'Referer' => 'http://stat.knetwork.ru/cabinet/',
            },
            content => JSON::PP->new()->encode({
                login => $login,
                password => $password,
            }),
        }
    );

    if ($response->{status} ne 200) {
        die "In login HTTP response code is not 200";
    }

    my $parsed_content = {};

    eval {
        $parsed_content = decode_json $response->{content};
    };

    if ($@) {
        die "Can't parse json from login response";
    }

    my $sid_customer = $parsed_content->{sid_customer};

    if (not defined $sid_customer) {
        die "No sid_customer in login response json";
    }

    if (length($sid_customer) != 36 ) {
        die "Unexpected sid_customer length in login response json";
    }

    return $sid_customer;
}

sub get_profile_data {
    my ($sid_customer) = @_;

    my $response = HTTP::Tiny->new()->request(
        'GET',
        'http://stat.knetwork.ru/customer_api/auth/profile',
        {
            headers => {
                'Content-Type' => 'application/json',

                'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
                'Accept' => 'application/json, text/plain, */*',
                'Accept-Language' => 'en-US,en;q=0.9',
                'Cache-Control' => 'no-cache',
                'Connection' => 'keep-alive',
                'Content-Type' => 'application/json;charset=UTF-8',
                'Origin' => 'http://stat.knetwork.ru',
                'Pragma' => 'no-cache',
                'Referer' => 'http://stat.knetwork.ru/cabinet/',
                'Cookie' => 'sid_customer=' . $sid_customer,
            },
        }
    );

    if ($response->{status} ne 200) {
        die "In profile HTTP response code is not 200";
    }

    my $parsed_content = {};

    eval {
        $parsed_content = decode_json $response->{content};
    };

    if ($@) {
        die "Can't parse json from profile response";
    }

    return $parsed_content;
}

sub get_balance {
    my ($profile_data) = @_;

    my $balance = $profile_data->{balance};

    if (defined($balance) && $balance > -10_000 && $balance < 10_000) {
        return(sprintf('%.2f', $balance) + 0);
    } else {
        die "Can't get info about balance";
    }
}

sub write_output {
    my ($balance) = @_;

    path('/output/output.json')->spew(to_pretty_json({
        is_success => JSON::PP::true,
        balance => $balance,
    }));
}

sub main {

    my $input_file_name = '/input/input.json';

    my $input_data = get_input_data($input_file_name);

    my $sid_customer = login(
        login => $input_data->{login},
        password => $input_data->{password},
    );

    my $profile_data = get_profile_data($sid_customer);

    my $balance = get_balance($profile_data);

    write_output($balance);

}
main();
