/* git2.h - libgit2 wrapper plugin header
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <git2.h>
#include <angelscript.h>
#include <scriptarray.h>
#include <string>
#include <cstring>

git_strarray as_strarray2git_strarray(CScriptArray* as_array);

class nvgt_git_repository_entry;
class nvgt_git_repository_commit;
class nvgt_git_repository_commit_iterator;
class nvgt_git_repository {
	git_repository* repo;
	git_index* index;
	int ref_count;
public:
	asIScriptFunction* match_callback;
	std::string match_callback_payload;
	nvgt_git_repository();
	void add_ref();
	void release();
	int open(const std::string& path);
	int create(const std::string& path);
	bool close();
	int add(const std::string& path);
	int add_all(CScriptArray* paths, int flags=0);
	int add_all_cb(CScriptArray* paths, int flags=0, asIScriptFunction* match_callback=NULL, const std::string& match_callback_payload="");
	int remove(const std::string& path);
	int remove_all(CScriptArray* paths);
	int remove_all_cb(CScriptArray* paths, asIScriptFunction* match_callback=NULL, const std::string& match_callback_payload="");
	int update_all(CScriptArray* paths);
	int update_all_cb(CScriptArray* paths, asIScriptFunction* match_callback=NULL, const std::string& match_callback_payload="");
	nvgt_git_repository_commit* commit_simple(const std::string& author, const std::string& author_email, const std::string& message, const std::string& ref="HEAD") { return commit(author, author_email, author, author_email, message, ref); }
	nvgt_git_repository_commit* commit(const std::string& author, const std::string& author_email, const std::string& committer, const std::string& committer_email, const std::string& message, const std::string& ref="HEAD");
	std::string commit_diff(nvgt_git_repository_commit* commit1, nvgt_git_repository_commit* commit2, unsigned int context_lines=3, unsigned int interhunk_lines=3, unsigned int flags=0, unsigned int format=1, CScriptArray* pathspec=NULL, const std::string& old_prefix="a", const std::string& new_prefix="b");
	nvgt_git_repository_commit* commit_lookup(const std::string& id);
	nvgt_git_repository_commit_iterator* commit_iterate(CScriptArray* path_filter=NULL, const std::string& author_filter="", const std::string& message_filter="", git_time_t min_time_filter=0, git_time_t max_time_filter=0, unsigned int start=0, unsigned int count=0);
	nvgt_git_repository_entry* get_entry(unsigned int n);
	nvgt_git_repository_entry* find_entry(const std::string& path);
	int get_entry_count();
	int get_is_empty();
	const std::string get_path();
	const std::string get_workdir();
	bool get_active() { return repo&&index; }
};

class nvgt_git_repository_commit {
	int ref_count;
	void get_signatures();
public:
	git_commit* commit;
	std::string committer, committer_email, author, author_email;
	nvgt_git_repository_commit(git_commit* c) : commit(c), ref_count(1) {}
	void add_ref() { asAtomicInc(ref_count); }
	void release() { if(asAtomicDec(ref_count)<1) { git_commit_free(commit); delete this; } }
	unsigned int get_time() { return git_commit_time(commit); }
	int get_parent_count() { return git_commit_parentcount(commit); }
	nvgt_git_repository_commit* get_parent(int idx);
	const std::string get_id() { const char* o=git_oid_tostr_s(git_commit_id(commit)); return std::string(o, strlen(o)); }
	const std::string get_message() { const char* m=git_commit_message(commit); if(!m) return ""; return std::string(m, strlen(m)); }
	const std::string get_summary() { const char* s=git_commit_summary(commit); return std::string(s, strlen(s)); }
	const std::string get_body() { const char* b=git_commit_body(commit); if(!b) return ""; return std::string(b, strlen(b)); }
	const std::string get_raw_header() { const char* h=git_commit_raw_header(commit); return std::string(h, strlen(h)); }
	const std::string get_committer() { get_signatures(); return committer; };
	const std::string get_committer_email() { get_signatures(); return committer_email; };
	const std::string get_author() { get_signatures(); return author; };
	const std::string get_author_email() { get_signatures(); return author_email; };
};
class nvgt_git_repository_commit_iterator {
	int ref_count;
	git_revwalk* walker;
	git_diff_options dopts;
	git_pathspec* pspec;
	std::string author_filter, message_filter;
	git_time_t min_time_filter, max_time_filter;
	int start, count, current_entry, inserted_entries;
public:
	nvgt_git_repository_commit* commit;
	nvgt_git_repository_commit_iterator(git_revwalk* w, CScriptArray* path_filter, const std::string& author_filter, const std::string& message_filter, git_time_t min_time_filter, git_time_t max_time_filter, unsigned int start, unsigned int count) : ref_count(1), walker(w), commit(NULL), dopts(GIT_DIFF_OPTIONS_INIT), author_filter(author_filter), message_filter(message_filter), min_time_filter(min_time_filter), max_time_filter(max_time_filter), start(start), count(count), current_entry(-1), inserted_entries(0), pspec(NULL) { if(path_filter&&path_filter->GetSize()>0) { dopts.pathspec=as_strarray2git_strarray(path_filter); git_pathspec_new(&pspec, &dopts.pathspec); } }
	void add_ref() { asAtomicInc(ref_count); }
	void release() { if(asAtomicDec(ref_count)<1) { git_revwalk_free(walker); if(dopts.pathspec.count) { free(dopts.pathspec.strings); git_pathspec_free(pspec); } if(commit) commit->release(); delete this; } }
	nvgt_git_repository_commit* get_commit() { commit->add_ref(); return commit; }
	bool next();
};

class nvgt_git_repository_entry {
	const git_index_entry* entry;
	int ref_count;
public:
	nvgt_git_repository_entry(const git_index_entry* e) : entry(e), ref_count(1) {}
	void add_ref() { asAtomicInc(ref_count); }
	void release() { if(asAtomicDec(ref_count)<1) delete this; }
	unsigned int get_ctime() { return entry->ctime.seconds; }
	unsigned int get_mtime() { return entry->mtime.seconds; }
	unsigned int get_file_size() { return entry->file_size; }
	const std::string get_oid() { const char* o=git_oid_tostr_s(&entry->id); return std::string(o, strlen(o)); }
	const std::string get_path() { return std::string((const char*)entry->path, strlen(entry->path)); }
};

void RegisterGit(asIScriptEngine* engine);
