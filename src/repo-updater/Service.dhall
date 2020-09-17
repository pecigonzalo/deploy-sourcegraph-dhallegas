let k8s = ../common/imports.dhall

let config = ./Config.dhall

in  k8s.Service::{
    , metadata = k8s.ObjectMeta::{
      , name = Some config.name
      , annotations = Some
        [ { mapKey = "prometheus.io/port", mapValue = "6060" }
        , { mapKey = "sourcegraph.prometheus/scrape", mapValue = "true" }
        ]
      , labels = Some (toMap ({ app = config.name } ⫽ config.labels))
      }
    , spec = Some k8s.ServiceSpec::{
      , type = Some "ClusterIP"
      , selector = Some (toMap { app = config.name })
      , ports = Some
        [ k8s.ServicePort::{
          , name = Some "http"
          , port = 3182
          , targetPort = Some (< Int : Natural | String : Text >.String "http")
          }
        ]
      }
    }
