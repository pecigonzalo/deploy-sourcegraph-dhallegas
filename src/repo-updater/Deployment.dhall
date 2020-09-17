let k8s = ../common/imports.dhall

let containers = ./Containers.dhall

let config = ./Config.dhall

let metadata =
      k8s.ObjectMeta::{
      , name = Some config.name
      , annotations = Some (toMap { description = config.description })
      , labels = Some
          ( toMap
              (   { sourcegraph-resource-requires = "no-cluster-admin" }
                ⫽ config.labels
              )
          )
      }

let templateMetadata =
      k8s.ObjectMeta::{
      , labels = Some (toMap ({ app = config.name } ⫽ config.labels))
      }

let spec =
      k8s.DeploymentSpec::{
      , selector = k8s.LabelSelector::{
        , matchLabels = Some (toMap { name = config.name })
        }
      , replicas = Some config.deployment.replicas
      , minReadySeconds = Some config.deployment.minReadySeconds
      , revisionHistoryLimit = Some config.deployment.revisionHistoryLimit
      , strategy = Some k8s.DeploymentStrategy::{
        , rollingUpdate = Some
          { maxSurge = Some
              ( < Int : Natural | String : Text >.Int
                  config.deployment.strategy.maxSurge
              )
          , maxUnavailable = Some
              ( < Int : Natural | String : Text >.Int
                  config.deployment.strategy.maxUnavailable
              )
          }
        , type = Some config.deployment.strategy.type
        }
      , template = k8s.PodTemplateSpec::{
        , metadata = templateMetadata
        , spec = Some k8s.PodSpec::{ containers }
        }
      }

in  k8s.Deployment::{ metadata, spec = Some spec }
