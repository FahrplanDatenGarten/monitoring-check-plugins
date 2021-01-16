#!/usr/bin/env python3
import argparse

import redis

parser = argparse.ArgumentParser()
parser.add_argument(
    "-tw",
    "--threshold-warn",
    type=int,
    help="Number of tasks that should not exist (exit code is warning)")
parser.add_argument(
    "-tc",
    "--threshold-critical",
    type=int,
    help="Number of tasks that must not exist (exit code is critical)",
    required=True)
parser.add_argument(
    "-b",
    "--broker",
    type=str,
    help="Celery Broker URL",
    required=True)
args = parser.parse_args()

queue_name = "celery"
client = redis.Redis.from_url(args.broker)
length = client.llen(queue_name)

if length is not None:
    length_str = "Number of tasks to do is: " + ", ".join(str(length))
else:
    length_str = "No tasks to do"

if length > args.threshold_critical:
    if args.threshold_warn:
        print(f"Celery cluster tasks CRITICAL: {length} tasks are to do|num_tasks={length};{args.threshold_warn};{args.threshold_critical}")
    else:
        print(f"Celery cluster tasks CRITICAL: {length} tasks are to do|num_tasks={length}")
    exit(2)
elif args.threshold_warn is not None and length > args.threshold_warn:
    print(f"Celery cluster tasks WARNING: {length} tasks are to do|num_tasks={length};{args.threshold_warn};{args.threshold_critical}")
    exit(1)
else:
    if args.threshold_warn:
        print(f"Celery cluster OK: {length} tasks are to do|num_tasks={length};{args.threshold_warn};{args.threshold_critical}")
    else:
        print(f"Celery cluster OK: {length} tasks are to do|num_tasks={length}")
    exit(0)
