-export([init_per_testcase/2, end_per_testcase/2, all/0]).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").
-include_lib("proper/include/proper.hrl").
-include_lib("snabbkaffe/include/snabbkaffe.hrl").
-include_lib("kernel/include/logger.hrl").

init_per_testcase(TestCase, Config) ->
  case os:getenv("KEEP_CT_LOGGING") of
    false ->
      ?LOG_NOTICE(asciiart:visible($%, "Running ~p", [TestCase]));
    _ ->
      ok
  end,
  Config1 = try apply(?MODULE, TestCase, [{init, Config}])
            catch
              error:function_clause -> Config
            end,
  ok = snabbkaffe:start_trace(),
  Config1.

end_per_testcase(TestCase, Config) ->
  try apply(?MODULE, TestCase, [{'end', Config}])
  catch
    error:function_clause -> ok
  end,
  snabbkaffe:analyze_statistics(),
  snabbkaffe_collector:stop(),
  case os:getenv("KEEP_CT_LOGGING") of
    false ->
      ?LOG_NOTICE(asciiart:visible($%, "End of ~p", [TestCase]));
    _ ->
      ok
  end,
  ok.

all() ->
  snabbkaffe:mk_all(?MODULE).
