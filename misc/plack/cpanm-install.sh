#!/bin/sh -xe

sudo cpan App::cpanminus
cpanm --sudo Task::Plack \
	Plack::Middleware::Static::Minifier \
	Plack::Middleware::Debug::Profiler::NYTProf \
	Plack::Middleware::Debug::DBIProfile

