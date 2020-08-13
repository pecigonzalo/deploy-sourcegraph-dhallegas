let k8s = ../common/imports.dhall

let jaeger = ../common/jaeger.dhall

let metadata =
      k8s.ObjectMeta::{
      , annotations = Some
          ( toMap
              { description =
                  "Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services."
              }
          )
      , labels = Some
          ( toMap
              { deploy = "sourcegraph"
              , sourcegraph-resource-requires = "no-cluster-admin"
              }
          )
      }

let templateMeta =
      k8s.ObjectMeta::{
      , labels = Some (toMap { deploy = "sourcegraph", app = "repo-updater" })
      }

let config =
      { name = "repo-updater"
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
      , strategy = k8s.DeploymentStrategy::{
        , rollingUpdate = Some
          { maxSurge = Some (< Int : Natural | String : Text >.Int 1)
          , maxUnavailable = Some (< Int : Natural | String : Text >.Int 0)
          }
        , type = Some "RollingUpdate"
        }
      }

let spec =
      k8s.DeploymentSpec::{
      , selector = k8s.LabelSelector::{
        , matchLabels = Some (toMap { name = config.name })
        }
      , minReadySeconds = Some 10
      , replicas = Some 1
      , revisionHistoryLimit = Some 10
      , strategy = Some config.strategy
      , template = k8s.PodTemplateSpec::{
        , metadata = templateMeta
        , spec = Some k8s.PodSpec::{
          , containers =
            [ k8s.Container::{
              , name = config.name
              , image = Some "${config.repo}:${config.tag}"
              , ports = Some config.ports
              , resources = Some config.resources
              }
            , jaeger
            ]
          }
        }
      }

let deployment =
      k8s.Deployment::{
      , apiVersion = "app/v1"
      , kind = "Deployment"
      , metadata
      , spec = Some spec
      }

in  { Type = k8s.Deployment.Type, default = deployment }
