document.addEventListener("click", function (e) {
  var b = e.target.closest("[data-door]");
  if (!b) return;
  document.querySelectorAll(".door").forEach(function (d) { d.classList.toggle("open", d.id === b.dataset.door); });
  document.querySelectorAll("[data-door]").forEach(function (x) { x.setAttribute("aria-pressed", String(x === b)); });
  document.getElementById(b.dataset.door).scrollIntoView({ behavior: "smooth", block: "start" });
});
