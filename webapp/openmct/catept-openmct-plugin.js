/* CAT/EPT Open MCT plugin with mission-view composition + live telemetry. */
(function () {
  function mergeConfig(defaults, overrides) {
    var out = {};
    var k;
    for (k in defaults) {
      if (Object.prototype.hasOwnProperty.call(defaults, k)) {
        out[k] = defaults[k];
      }
    }
    if (overrides && typeof overrides === "object") {
      for (k in overrides) {
        if (Object.prototype.hasOwnProperty.call(overrides, k)) {
          out[k] = overrides[k];
        }
      }
    }
    return out;
  }

  function withSlash(value) {
    var s = String(value || "").trim();
    return s.endsWith("/") ? s.slice(0, -1) : s;
  }

  function makeIdentifier(cfg, key) {
    return { namespace: cfg.namespace, key: String(key) };
  }

  function idFromIdentifier(cfg, identifier) {
    if (!identifier || identifier.namespace !== cfg.namespace) {
      return "";
    }
    return String(identifier.key || "");
  }

  function fetchJson(url) {
    return fetch(url).then(function (resp) {
      if (!resp.ok) {
        throw new Error("HTTP " + resp.status + " for " + url);
      }
      return resp.json();
    });
  }

  function normalizeMissionViews(rawViews) {
    if (!Array.isArray(rawViews)) {
      return [];
    }
    var seen = new Set();
    var out = [];
    rawViews.forEach(function (item) {
      if (!item || typeof item !== "object") {
        return;
      }
      var key = String(item.key || "").trim();
      if (!key || seen.has(key)) {
        return;
      }
      seen.add(key);
      out.push({
        key: key,
        id: "mission.view." + key,
        name: String(item.name || key),
        explicitChannels: Array.isArray(item.explicitChannels)
          ? item.explicitChannels.map(String)
          : [],
        channelPrefixes: Array.isArray(item.channelPrefixes)
          ? item.channelPrefixes.map(String)
          : []
      });
    });
    return out;
  }

  function buildMissionChannelMap(cache, views) {
    var byViewId = new Map();
    var allIds = Array.isArray(cache.ids) ? cache.ids : [];
    views.forEach(function (view) {
      var selected = [];
      var selectedSet = new Set();

      view.explicitChannels.forEach(function (channelId) {
        if (cache.byId.has(channelId) && !selectedSet.has(channelId)) {
          selectedSet.add(channelId);
          selected.push(channelId);
        }
      });

      allIds.forEach(function (channelId) {
        if (selectedSet.has(channelId)) {
          return;
        }
        var matched = view.channelPrefixes.some(function (prefix) {
          return channelId.startsWith(prefix);
        });
        if (matched) {
          selectedSet.add(channelId);
          selected.push(channelId);
        }
      });

      byViewId.set(view.id, selected);
    });
    return byViewId;
  }

  function toFolderObject(cfg, id, name, location) {
    return {
      identifier: makeIdentifier(cfg, id),
      name: String(name || id),
      type: "folder",
      location: location || "ROOT"
    };
  }

  function toTelemetryObject(cfg, id, source) {
    var obj = source || {};
    return {
      identifier: makeIdentifier(cfg, id),
      name: String(obj.name || id),
      type: "telemetry",
      telemetry: obj.telemetry || {
        values: [
          { key: "value", name: "Value", format: "number", hints: { range: 1 } },
          { key: "timestamp", name: "Timestamp", format: "utc", hints: { domain: 1 } },
          { key: "status", name: "Status", format: "string" },
          { key: "artifact", name: "Artifact", format: "string" },
          { key: "task_id", name: "Task ID", format: "string" }
        ]
      }
    };
  }

  window.CATEPTOpenMCTPlugin = function CATEPTOpenMCTPlugin(userConfig) {
    var cfg = mergeConfig(
      {
        adapterBaseUrl: "http://127.0.0.1:8093",
        namespace: "catept",
        rootKey: "root",
        missionRootKey: "mission.views",
        channelsRootKey: "channels.all",
        pollMs: 4000,
        windowMs: 90000,
        missionViews: []
      },
      userConfig
    );

    cfg.adapterBaseUrl = withSlash(cfg.adapterBaseUrl);
    cfg.missionViews = normalizeMissionViews(cfg.missionViews);

    var objectCache = {
      loaded: false,
      byId: new Map(),
      ids: [],
      missionViews: [],
      missionById: new Map(),
      missionChannels: new Map()
    };

    function loadObjects() {
      if (objectCache.loaded) {
        return Promise.resolve(objectCache);
      }
      return fetchJson(cfg.adapterBaseUrl + "/api/openmct/objects").then(function (payload) {
        var objs = Array.isArray(payload.objects) ? payload.objects : [];
        objectCache.byId = new Map();
        objectCache.ids = [];
        objs.forEach(function (obj) {
          if (obj && obj.id) {
            var id = String(obj.id);
            objectCache.byId.set(id, obj);
            objectCache.ids.push(id);
          }
        });
        objectCache.missionViews = cfg.missionViews.slice();
        objectCache.missionById = new Map();
        objectCache.missionViews.forEach(function (view) {
          objectCache.missionById.set(view.id, view);
        });
        objectCache.missionChannels = buildMissionChannelMap(
          objectCache,
          objectCache.missionViews
        );
        objectCache.loaded = true;
        return objectCache;
      });
    }

    function fetchTelemetrySeries(id, options) {
      var params = new URLSearchParams();
      params.set("id", id);
      if (options && typeof options.start === "number") {
        params.set("start", String(Math.floor(options.start)));
      }
      if (options && typeof options.end === "number") {
        params.set("end", String(Math.floor(options.end)));
      }
      return fetchJson(cfg.adapterBaseUrl + "/api/openmct/telemetry?" + params.toString()).then(function (payload) {
        var samples = Array.isArray(payload.samples) ? payload.samples : [];
        return samples.map(function (s) {
          return {
            timestamp: typeof s.timestamp === "number" ? s.timestamp : 0,
            value: typeof s.value === "number" ? s.value : Number(s.value || 0),
            status: s.status || "",
            artifact: s.artifact || "",
            task_id: s.task_id || ""
          };
        });
      });
    }

    function isKnownFolderId(cache, id) {
      if (id === cfg.rootKey || id === cfg.missionRootKey || id === cfg.channelsRootKey) {
        return true;
      }
      return cache.missionById.has(id);
    }

    return function install(openmct) {
      openmct.objects.addRoot(makeIdentifier(cfg, cfg.rootKey));

      openmct.objects.addProvider(cfg.namespace, {
        get: function (identifier) {
          var id = idFromIdentifier(cfg, identifier);
          return loadObjects().then(function (cache) {
            if (id === cfg.rootKey) {
              return toFolderObject(cfg, cfg.rootKey, "CAT/EPT Telemetry", "ROOT");
            }
            if (id === cfg.missionRootKey) {
              return toFolderObject(
                cfg,
                cfg.missionRootKey,
                "Mission Views",
                cfg.namespace + ":" + cfg.rootKey
              );
            }
            if (id === cfg.channelsRootKey) {
              return toFolderObject(
                cfg,
                cfg.channelsRootKey,
                "All Channels",
                cfg.namespace + ":" + cfg.rootKey
              );
            }
            if (cache.missionById.has(id)) {
              var view = cache.missionById.get(id);
              return toFolderObject(
                cfg,
                id,
                view.name,
                cfg.namespace + ":" + cfg.missionRootKey
              );
            }
            var raw = cache.byId.get(id);
            if (!raw) {
              return undefined;
            }
            return toTelemetryObject(cfg, id, raw);
          });
        }
      });

      openmct.composition.addProvider({
        appliesTo: function (domainObject) {
          return (
            domainObject &&
            domainObject.type === "folder" &&
            domainObject.identifier &&
            domainObject.identifier.namespace === cfg.namespace
          );
        },
        load: function (domainObject) {
          var id = idFromIdentifier(cfg, domainObject.identifier);
          return loadObjects().then(function (cache) {
            if (!isKnownFolderId(cache, id)) {
              return [];
            }
            if (id === cfg.rootKey) {
              var children = [];
              if (cache.missionViews.length > 0) {
                children.push(makeIdentifier(cfg, cfg.missionRootKey));
              }
              children.push(makeIdentifier(cfg, cfg.channelsRootKey));
              return children;
            }
            if (id === cfg.missionRootKey) {
              return cache.missionViews.map(function (view) {
                return makeIdentifier(cfg, view.id);
              });
            }
            if (id === cfg.channelsRootKey) {
              return cache.ids.map(function (channelId) {
                return makeIdentifier(cfg, channelId);
              });
            }
            if (cache.missionById.has(id)) {
              var channels = cache.missionChannels.get(id) || [];
              return channels.map(function (channelId) {
                return makeIdentifier(cfg, channelId);
              });
            }
            return [];
          });
        }
      });

      openmct.telemetry.addProvider({
        supportsRequest: function (domainObject) {
          return (
            domainObject &&
            domainObject.identifier &&
            domainObject.identifier.namespace === cfg.namespace &&
            domainObject.identifier.key !== cfg.rootKey &&
            domainObject.identifier.key !== cfg.missionRootKey &&
            domainObject.identifier.key !== cfg.channelsRootKey &&
            !String(domainObject.identifier.key).startsWith("mission.view.")
          );
        },
        request: function (domainObject, options) {
          var id = idFromIdentifier(cfg, domainObject.identifier);
          return fetchTelemetrySeries(id, options || {});
        },
        supportsSubscribe: function (domainObject) {
          return (
            domainObject &&
            domainObject.identifier &&
            domainObject.identifier.namespace === cfg.namespace &&
            domainObject.identifier.key !== cfg.rootKey &&
            domainObject.identifier.key !== cfg.missionRootKey &&
            domainObject.identifier.key !== cfg.channelsRootKey &&
            !String(domainObject.identifier.key).startsWith("mission.view.")
          );
        },
        subscribe: function (domainObject, callback) {
          var stopped = false;
          var timer = null;
          var id = idFromIdentifier(cfg, domainObject.identifier);

          function poll() {
            if (stopped) {
              return;
            }
            var now = Date.now();
            fetchTelemetrySeries(id, {
              start: now - Number(cfg.windowMs || 90000),
              end: now
            })
              .then(function (samples) {
                if (samples.length > 0) {
                  callback(samples[samples.length - 1]);
                }
              })
              .catch(function () {
                // Keep polling; transient failures should not terminate the stream.
              })
              .finally(function () {
                if (!stopped) {
                  timer = setTimeout(poll, Number(cfg.pollMs || 4000));
                }
              });
          }

          poll();

          return function unsubscribe() {
            stopped = true;
            if (timer) {
              clearTimeout(timer);
              timer = null;
            }
          };
        }
      });
    };
  };
})();
