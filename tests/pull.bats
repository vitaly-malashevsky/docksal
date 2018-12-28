#!/usr/bin/env bats

# Debugging
teardown() {
	echo "Status: $status"
	echo "Output:"
	echo "================================================================"
	for line in "${lines[@]}"; do
		echo $line
	done
	echo "================================================================"
}

# Add project_key to SSH Agent.
[[ "$TRAVIS" == "true" ]] && fin ssh-key add project_key

# Test interacting with Providers
@test "fin pull: acquia" {
	#[[ $SKIP == 1 ]] && skip

	# Setup
	fin config set --global "SECRET_ACAPI_EMAIL=${BUILD_ACAPI_EMAIL}"
	fin config set --global "SECRET_ACAPI_KEY=${BUILD_ACAPI_TOKEN}"

	# Test Initialize Project
	run fin pull init --HOSTING_PLATFORM=acquia --HOSTING_SITE=${BUILD_ACQUIA_SITE} --HOSTING_ENV=${BUILD_ACQUIA_ENV} pull-site
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Starting Pull Init Process" ]]
	[[ "${output}" =~ "Pulling code complete" ]]
	unset output

	cd pull-site
	fin start

	# Test Pull Code
	run fin pull code
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Pulling code" ]]
	[[ "${output}" =~ "Code Pull Successful" ]]
	unset output

	# Test Pull DB

	## Test Acquia Pull without db name
	run fin pull db
	[[ "$status" == 1 ]]
	[[ "${output}" =~ "Database name is required." ]]
	unset output

	## Test Acquia Pull with db name
	run fin pull db ${BUILD_ACQUIA_SITE}
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Pulling new database file..." ]]
	# Depending on when test is ran may get a backup in the last 24 hours.
	# May need to create one
	[[ "${output}" =~ "Creating new backup on Acquia" ]] ||
		[[ "${output}" =~ "Using latest backup from Acquia" ]]
	[[ "${output}" =~ "DB Pull Successful" ]]
	unset output

	## Test Acquia Pull with Cached Version
	run fin pull db ${BUILD_ACQUIA_SITE}
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Cached DB file still valid found and using to import" ]]
	[[ "${output}" =~ "DB Pull Successful" ]]
	unset output

	## Test Acquia Pull with --FORCE flag
	run fin pull db ${BUILD_ACQUIA_SITE} --FORCE
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Pulling new database file..." ]]
	[[ "${output}" =~ "Creating new backup on Acquia" ]]
	[[ "${output}" =~ "DB Pull Successful" ]]
	unset output

	# Test Pull Files
	run fin pull files
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Downloading files from" ]]
	[[ "${output}" =~ "File Pull Successful" ]]
	unset output

	# Test Pull All
	run fin pull
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting provider pull on acquia" ]]
	[[ "${output}" =~ "Code Pull Successful" ]]
	[[ "${output}" =~ "DB Pull Successful" ]]
	[[ "${output}" =~ "File Pull Successful" ]]
	unset output

	# Cleanup
	fin rm -f
	cd ..
	rm -rf pull-site
}

@test "fin pull: pantheon" {
	#[[ $SKIP == 1 ]] && skip

	# Setup
	fin config set --global "SECRET_TERMINUS_TOKEN=${BUILD_TERMINUS_TOKEN}"

	# Test Initialize Project
	run fin pull init --HOSTING_PLATFORM=pantheon --HOSTING_SITE=${BUILD_PANTHEON_SITE} --HOSTING_ENV=${BUILD_PANTHEON_ENV} pull-site
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting Pull Init Process" ]]
	[[ "${output}" =~ "Pulling code complete" ]]
	unset output

	cd pull-site
	fin start

	# Test Pull Code
	run fin pull code
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on pantheon" ]]
	[[ "${output}" =~ "Pulling Code" ]]
	unset output

	# Test Pull DB
	run fin pull db
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on pantheon" ]]
	unset output

	# Test Pull Files
	run fin pull files
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on pantheon" ]]
	unset output

	# Test Pull All
	run fin pull
	[[ $status == 0 ]]
    [[ "${output}" =~ "Starting provider pull on pantheon" ]]
    [[ "${output}" =~ "Code Pull Successful" ]]
    [[ "${output}" =~ "DB Pull Successful" ]]
    [[ "${output}" =~ "File Pull Successful" ]]
	unset output

	# Cleanup
	fin rm -f
	cd ..
	rm -rf pull-site
}

@test "fin pull: platform.sh" {
	#[[ $SKIP == 1 ]] && skip

	# Setup
	fin config set --global "SECRET_PLATFORMSH_CLI_TOKEN=${BUILD_PLATFORMSH_CLI_TOKEN}"

	# Test Initialize Project
	run fin pull init --HOSTING_PLATFORM=platformsh --HOSTING_SITE=${BUILD_PLATFORMSH_SITE} --HOSTING_ENV=${BUILD_PLATFORMSH_ENV} pull-site
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting Pull Init Process" ]]
	[[ "${output}" =~ "Pulling code complete" ]]
	unset output

	cd pull-site
	fin start

	# Test Pull Code
	run fin pull code
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on platformsh" ]]
	[[ "${output}" =~ "Pulling Code" ]]
	unset output

	# Test Pull DB
	run fin pull db
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on platformsh" ]]
	unset output

	# Test Pull Files
	run fin pull files
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on platformsh" ]]
	unset output

	# Test Pull All
	run fin pull
	[[ $status == 0 ]]
    [[ "${output}" =~ "Starting provider pull on platformsh" ]]
    [[ "${output}" =~ "Code Pull Successful" ]]
    [[ "${output}" =~ "DB Pull Successful" ]]
    [[ "${output}" =~ "File Pull Successful" ]]
	unset output

	# Cleanup
	fin rm -f
	cd ..
	rm -rf pull-site
}

@test "fin pull: drush" {
	#[[ $SKIP == 1 ]] && skip

	# Test Initialize Project
	run fin pull init --HOSTING_PLATFORM=drush --HOSTING_SITE=dev https://github.com/docksal/drupal8.git pull-site
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting Pull Init Process" ]]
	[[ "${output}" =~ "Pulling code complete" ]]
	unset output

	cd pull-site
	fin start

	# Test Pull Code
	run fin pull code
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on drush" ]]
	[[ "${output}" =~ "Pulling Code" ]]
	unset output

	# Test Pull DB
	run fin pull db
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on drush" ]]
	unset output

	# Test Pull Files
	run fin pull files
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on drush" ]]
	unset output

	# Test Pull All
	run fin pull
	[[ $status == 0 ]]
    [[ "${output}" =~ "Starting provider pull on drush" ]]
    [[ "${output}" =~ "Code Pull Successful" ]]
    [[ "${output}" =~ "DB Pull Successful" ]]
    [[ "${output}" =~ "File Pull Successful" ]]
	unset output

	# Cleanup
	fin rm -f
	cd ..
	rm -rf pull-site
}

@test "fin pull: wp" {
	#[[ $SKIP == 1 ]] && skip

	# Test Initialize Project
	run fin pull init --HOSTING_PLATFORM=wp --HOSTING_SITE=test https://github.com/docksal/wordpress.git pull-site
	[[ "$status" == 0 ]]
	[[ "${output}" =~ "Starting Pull Init Process" ]]
	[[ "${output}" =~ "Pulling code complete" ]]
	unset output

	cd pull-site
	fin start

	# Test Pull Code
	run fin pull code
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on wp" ]]
	[[ "${output}" =~ "Pulling Code" ]]
	unset output

	# Test Pull DB
	run fin pull db
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on wp" ]]
	unset output

	# Test Pull Files
	run fin pull files
	[[ $status == 0 ]]
	[[ "${output}" =~ "Starting provider pull on wp" ]]
	unset output

	# Test Pull All
	run fin pull
	[[ $status == 0 ]]
    [[ "${output}" =~ "Starting provider pull on wp" ]]
    [[ "${output}" =~ "Code Pull Successful" ]]
    [[ "${output}" =~ "DB Pull Successful" ]]
    [[ "${output}" =~ "File Pull Successful" ]]

	# Cleanup
	fin rm -f
	cd ..
	rm -rf pull-site
}
