#!/usr/bin/env bats

load ../helpers

function teardown() {
	swarm_manage_cleanup
	stop_docker
}

@test "docker run" {
	start_docker_with_busybox 2
	swarm_manage

	# make sure no container exist
	run docker_swarm ps -qa
	[ "${#lines[@]}" -eq 0 ]

	# run
	docker_swarm run -d --name test_container busybox sleep 100

	# verify, container is running
	[ -n $(docker_swarm ps -q --filter=name=test_container --filter=status=running) ]
}

@test "docker run not enough resources" {
	start_docker_with_busybox 1
	swarm_manage

	run docker_swarm run -d --name test_container -m 1000g busybox ls
	[ "$status" -ne 0 ]

	run docker_swarm run -d --name test_container -c 1000 busybox ls
	[ "$status" -ne 0 ]
}
