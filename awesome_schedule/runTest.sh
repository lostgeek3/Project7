#!/bin/bash

# Run the test
flutter test test/database_test.dart --coverage
mv coverage/lcov.info coverage/lcov_db.info
# Generate the coverage report
genhtml coverage/lcov_db.info -o coverage/html_db

flutter test test/model_test.dart --coverage
mv coverage/lcov.info coverage/lcov_md.info
genhtml coverage/lcov_md.info -o coverage/html_md

# Open the coverage report
open coverage/html_db/index.html
open coverage/html_md/index.html