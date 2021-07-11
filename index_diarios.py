import time
from pathlib import Path

import elasticsearch


INDEX = "diarios"
ROOT = Path(__file__).parent
DATA = ROOT/ 'data' / 'serra-3205002-processed'


def delete_index(es):
    for attempt in range(3):
        try:
            es.indices.delete(index=INDEX, ignore_unavailable=True, timeout="30s")
            es.indices.refresh()
            print("Index deleted")
            return
        except Exception as e:
            print("Index deletion failed")
            time.sleep(10)


def create_index(es):
    for attempt in range(3):
        try:
            es.indices.create(
                index=INDEX,
                timeout="30s",
            )
            es.indices.refresh()
            print(f"Index {INDEX} created")
            return
        except Exception as e:
            print(f"Index creation failed: {e}")
            time.sleep(10)

def index_exists(es):
    return es.indices.exists(index=INDEX)

def recreate_index(es):
    if index_exists(es):
        delete_index(es)

    create_index(es)

def is_cluster_running(es):
    print("Checking if cluster is running")
    if es.ping():
        return True

    for attempt in range(3):
        print("Waiting for cluster to start running")
        time.sleep(10)
        if es.ping():
            return True

    print("Cluster is not running. Unable to proceed")
    return False

def add_data_on_index(data, es):
    for i, record in enumerate(data):
        es.index(index=INDEX, id=i, body={"text": record})


def get_data():
    for diario_file in DATA.glob("*/*/*.txt"):
        yield diario_file.read_text()


def main():
    es = elasticsearch.Elasticsearch(hosts=["localhost"])

    if not is_cluster_running(es):
        return

    recreate_index(es)
    add_data_on_index(get_data(), es)


if __name__ == "__main__":
    main()
