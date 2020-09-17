let k8s = ../common/imports.dhall

let config =
      { name = "repo-updater"
      , labels.deploy = "sourcegraph"
      , description =
          "Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services."
      , repo = "index.docker.io/sourcegraph/repo-updater"
      , tag =
          "3.18.0@sha256:1a4992837e6abcc976fc22a7ccf15688c7b94b0361cd9896d851a03c0556b39e"
      , ports =
        [ k8s.ContainerPort::{ containerPort = 3182, name = Some "http" }
        , k8s.ContainerPort::{ containerPort = 6060, name = Some "debug" }
        ]
      , resources = k8s.ResourceRequirements::{
        , limits = Some (toMap { cpu = "100m", memory = "500Mi" })
        , requests = Some (toMap { cpu = "100m", memory = "500Mi" })
        }
      , deployment =
        { strategy =
          { maxSurge = 1, maxUnavailable = 0, type = "RollingUpdate" }
        , minReadySeconds = 10
        , replicas = 1
        , revisionHistoryLimit = 10
        }
      }

in  config
