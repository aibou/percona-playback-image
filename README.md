# Build

(docker composeでbuildするので特に不要ですが、単独でビルドしたい場合は以下のコマンド)

```
export GITHUB_ACTOR=${your github account name}
export GITHUB_TOKEN=${your github personal access token}
docker buildx build --platform linux/amd64 --secret id=github-actor,env=GITHUB_ACTOR --secret id=github-token,env=GITHUB_TOKEN -t percona-playback .
```

# Run

```
export GITHUB_ACTOR=${your github account name}
export GITHUB_TOKEN=${your github personal access token}

cp ~/some/of/mysql-general.log logs
docker compose run cmd percona-playback
```

```
docker-compose run cmd percona-playback \
  --input-plugin general-log \
  --mysql-max-retries 0 \
  --mysql-schema ${database}  \
  --mysql-test-connect off \
  --general-log-file /data/mysql-general.log \
  --mysql-host 'localhost' \
  --mysql-username 'root' \
  --mysql-password '******'
```

# Ubuntu version

現状18.04でしかbuildできない

## 20.04

C++のBoostのメソッド名が変わってビルドエラー

```
357.5 /query-playback/percona_playback/simple_report/simple_report.cc: In member function 'virtual void SimpleReportPlugin::print_report()':
357.5 /query-playback/percona_playback/simple_report/simple_report.cc:167:109: error: no matching function for call to 'boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>::subsecond_duration(tbb::atomic<long unsigned int>&)'
357.5   167 |     boost::posix_time::time_duration total_duration= boost::posix_time::microseconds(total_execution_time_ms);
357.5       |                                                                                                             ^
357.5 In file included from /usr/include/boost/date_time/posix_time/posix_time_config.hpp:16,
357.5                  from /usr/include/boost/date_time/posix_time/posix_time_system.hpp:13,
357.5                  from /usr/include/boost/date_time/posix_time/ptime.hpp:12,
357.5                  from /usr/include/boost/date_time/posix_time/posix_time.hpp:15,
357.5                  from /query-playback/percona_playback/simple_report/simple_report.cc:24:
357.5 /usr/include/boost/date_time/time_duration.hpp:285:14: note: candidate: 'template<class T> boost::date_time::subsecond_duration<base_duration, frac_of_second>::subsecond_duration(const T&, typename boost::enable_if<boost::is_integral<Functor>, void>::type*)'
357.5   285 |     explicit subsecond_duration(T const& ss,
357.5       |              ^~~~~~~~~~~~~~~~~~
357.5 /usr/include/boost/date_time/time_duration.hpp:285:14: note:   template argument deduction/substitution failed:
357.5 /usr/include/boost/date_time/time_duration.hpp: In substitution of 'template<class T> boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>::subsecond_duration(const T&, typename boost::enable_if<boost::is_integral<T> >::type*) [with T = tbb::atomic<long unsigned int>]':
357.5 /query-playback/percona_playback/simple_report/simple_report.cc:167:109:   required from here
357.5 /usr/include/boost/date_time/time_duration.hpp:285:14: error: no type named 'type' in 'struct boost::enable_if<boost::is_integral<tbb::atomic<long unsigned int> >, void>'
357.5 In file included from /usr/include/boost/date_time/posix_time/posix_time_config.hpp:16,
357.5                  from /usr/include/boost/date_time/posix_time/posix_time_system.hpp:13,
357.5                  from /usr/include/boost/date_time/posix_time/ptime.hpp:12,
357.5                  from /usr/include/boost/date_time/posix_time/posix_time.hpp:15,
357.5                  from /query-playback/percona_playback/simple_report/simple_report.cc:24:
357.5 /usr/include/boost/date_time/time_duration.hpp:270:30: note: candidate: 'boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>::subsecond_duration(const boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>&)'
357.5   270 |   class BOOST_SYMBOL_VISIBLE subsecond_duration : public base_duration
357.5       |                              ^~~~~~~~~~~~~~~~~~
357.5 /usr/include/boost/date_time/time_duration.hpp:270:30: note:   no known conversion for argument 1 from 'tbb::atomic<long unsigned int>' to 'const boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>&'
357.5 /usr/include/boost/date_time/time_duration.hpp:270:30: note: candidate: 'boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>::subsecond_duration(boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>&&)'
357.5 /usr/include/boost/date_time/time_duration.hpp:270:30: note:   no known conversion for argument 1 from 'tbb::atomic<long unsigned int>' to 'boost::date_time::subsecond_duration<boost::posix_time::time_duration, 1000000>&&'
```

## 22.04以降

TBBが `tbb/tbb_stddef.h` を削除したので、デフォルトでインストールできない
- libtbb-dev.2020 -> OK
- libtbb-dev.2021 -> NG

```
79.15 /query-playback/percona_playback/error_report/error_report.cc:25:10: fatal error: tbb/tbb_stddef.h: No such file or directory
79.15    25 | #include <tbb/tbb_stddef.h>
79.15       |          ^~~~~~~~~~~~~~~~~~
```
