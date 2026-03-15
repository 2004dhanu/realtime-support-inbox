import argparse

from app.store.seed import seed_data


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=28)
    args = parser.parse_args()
    seed_data(args.count)
    print(f"Seeded {args.count} conversations")


if __name__ == "__main__":
    main()
