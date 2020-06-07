SELECT C.ID,C.author_name,R.* FROM  COMMITS C (NOLOCK) JOIN  RULES_PIVOT  R(NOLOCK) 
ON C.committer_hash = R.commit_hash
