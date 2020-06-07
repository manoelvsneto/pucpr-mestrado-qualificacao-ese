from pydriller import RepositoryMining
import pyodbc

def inserir(_committer_date, _author_name, _hash, _project, _worker):
    conn = pyodbc.connect("Driver={SQL Server};"
                          "Server=localhost;"
                          "Database=Repository2;"
                          "uid=user;pwd=Password")
    cursor = conn.cursor()
    _author_name = _author_name.replace("'", "")
    cursor.execute(
        f"INSERT INTO Repository2.dbo.commits (author_name, committer_hash, committer_date,project_name,worker) VALUES ('{_author_name}','{_hash}','{_committer_date}','{_project}',{_worker})")
    conn.commit()


def insertCommits(_project,_version):
    x = 1
    for commit in RepositoryMining(f"C:\\processamento_sonar\\git-{_version}\\{_project}").traverse_commits():
        print(commit.hash)
        inserir(commit.committer_date.strftime("%d/%m/%Y %H:%M:%S"), commit.author.name, commit.hash, _project, x)


insertCommits('wordpress-1')


