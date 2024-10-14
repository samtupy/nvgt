#pragma once

#ifdef __cplusplus
extern "C" {
#endif
int sqlite3_db_dump( sqlite3 *db, const char *zSchema, const char *zTable, int (*xCallback)(const char*,void*), void *pArg);
int sqlite3_eval_init( sqlite3 *db,  char **pzErrMsg,  const sqlite3_api_routines *pApi);
#ifdef __cplusplus
}
#endif
