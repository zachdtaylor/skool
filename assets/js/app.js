// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { computePosition, flip, shift, offset, arrow } from "@floating-ui/dom";
import topbar from "../vendor/topbar";

let Hooks = {};

Hooks.GoBack = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      window.history.back();
    });
  },
};

Hooks.OptimisticRemove = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      let { removeId, event, ...payload } = this.el.dataset;
      let elToRemove = document.getElementById(removeId);
      elToRemove.remove();
      this.pushEvent(event, payload);
    });
  },
};

Hooks.Tooltip = {
  mounted() {
    const button = this.el.querySelector(".tooltip-trigger");
    const tooltip = this.el.querySelector(".tooltip-content");
    const arrowEl = this.el.querySelector(".tooltip-arrow");

    function update() {
      computePosition(button, tooltip, {
        placement: "top",
        middleware: [
          flip(),
          shift({ padding: 5 }),
          offset(6),
          arrow({ element: arrowEl }),
        ],
      }).then(({ x, y, placement, middlewareData }) => {
        Object.assign(tooltip.style, {
          left: `${x}px`,
          top: `${y}px`,
        });

        const { x: arrowX, y: arrowY } = middlewareData.arrow;

        const staticSide = {
          top: "bottom",
          right: "left",
          bottom: "top",
          left: "right",
        }[placement.split("-")[0]];

        Object.assign(arrowEl.style, {
          left: arrowX != null ? `${arrowX}px` : "",
          top: arrowY != null ? `${arrowY}px` : "",
          right: "",
          bottom: "",
          [staticSide]: "-4px",
        });
      });
    }

    function showTooltip() {
      tooltip.style.display = "block";
      update();
    }

    function hideTooltip() {
      tooltip.style.display = "";
    }

    [
      ["mouseenter", showTooltip],
      ["mouseleave", hideTooltip],
      ["focus", showTooltip],
      ["blur", hideTooltip],
    ].forEach(([event, listener]) => {
      button.addEventListener(event, listener);
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
