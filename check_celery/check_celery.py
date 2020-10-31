import argparse

from celery import Celery

parser = argparse.ArgumentParser()
parser.add_argument(
    "-tw",
    "--threshold-warn",
    type=int,
    help="Number of workers that should exist (exit code is warning)")
parser.add_argument(
    "-tc",
    "--threshold-critical",
    type=int,
    help="Number of workers that must exist (exit code is critical)",
    required=True)
parser.add_argument(
    "-b",
    "--broker",
    type=str,
    help="Celery Broker URL",
    required=True)
args = parser.parse_args()

app = Celery(
    broker=args.broker
)

i = app.control.inspect()
worker_ping = i.ping()

online_workers = [worker[0] for worker in worker_ping.items()]
online_workers.sort()
online_workers_str = "Online workers are: " + ", ".join(online_workers)

if len(worker_ping) < args.threshold_critical:
    if args.threshold_warn:
        print(f"Celery cluster CRITICAL: {len(worker_ping)} workers are connected|num_workers={len(worker_ping)};{args.threshold_warn};{args.threshold_critical}")
    else:
        print(f"Celery cluster CRITICAL: {len(worker_ping)} workers are connected|num_workers={len(worker_ping)}")
    print(online_workers_str)
    exit(2)
elif args.threshold_warn is not None and len(worker_ping) < args.threshold_warn:
    print(f"Celery cluster WARNING: {len(worker_ping)} workers are connected|num_workers={len(worker_ping)};{args.threshold_warn};{args.threshold_critical}")
    print(online_workers_str)
    exit(1)
else:
    if args.threshold_warn:
        print(f"Celery cluster OK: {len(worker_ping)} workers are connected|num_workers={len(worker_ping)};{args.threshold_warn};{args.threshold_critical}")
    else:
        print(f"Celery cluster OK: {len(worker_ping)} workers are connected|num_workers={len(worker_ping)}")
    exit(0)
