## The tests under the JavaScript backend: `nim js -d:nodejs -r tests/js.nim`.
## All of `all.nim` but the nimib tests (nimib writes files); a test that needs a file says so with `when defined(js)`.
import test_core, test_formats, test_render, test_v01, test_summary, test_rows_cols, test_more_formats, test_locales, test_table_tools, test_pair_blocks, test_pictures, test_lists_records, test_finish_0_2
