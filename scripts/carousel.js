(function () {
  var carousel = document.getElementById("screenshot-carousel");
  if (!carousel) return;

  var slides = carousel.querySelectorAll(".device-frame__slide");
  var dotsContainer = document.getElementById("carousel-dots");
  var prevBtn = carousel.querySelector(".screenshot-carousel__nav--prev");
  var nextBtn = carousel.querySelector(".screenshot-carousel__nav--next");
  var lightbox = document.getElementById("lightbox");
  var lightboxImg = lightbox && lightbox.querySelector(".lightbox__img");
  var lightboxClose = lightbox && lightbox.querySelector(".lightbox__close");
  var current = 0;
  var total = slides.length;

  if (!total || !dotsContainer) return;

  slides.forEach(function (_, i) {
    var dot = document.createElement("button");
    dot.type = "button";
    dot.className = "device-frame__dot" + (i === 0 ? " device-frame__dot--active" : "");
    dot.setAttribute("aria-label", "Screenshot " + (i + 1));
    dot.addEventListener("click", function () {
      goTo(i);
    });
    dotsContainer.appendChild(dot);
  });

  var dots = dotsContainer.querySelectorAll(".device-frame__dot");

  function goTo(index) {
    current = (index + total) % total;
    slides.forEach(function (slide, i) {
      slide.classList.toggle("is-active", i === current);
    });
    dots.forEach(function (dot, i) {
      dot.classList.toggle("device-frame__dot--active", i === current);
    });
  }

  function openLightbox() {
    if (!lightbox || !lightboxImg) return;
    var img = slides[current].querySelector("img");
    if (!img) return;
    lightboxImg.src = img.src;
    lightboxImg.alt = img.alt;
    lightbox.hidden = false;
    lightbox.setAttribute("aria-hidden", "false");
    requestAnimationFrame(function () {
      lightbox.classList.add("is-open");
    });
    document.body.style.overflow = "hidden";
  }

  function closeLightbox() {
    if (!lightbox) return;
    lightbox.classList.remove("is-open");
    lightbox.setAttribute("aria-hidden", "true");
    document.body.style.overflow = "";
    setTimeout(function () {
      lightbox.hidden = true;
      if (lightboxImg) lightboxImg.src = "";
    }, 300);
  }

  prevBtn.addEventListener("click", function () {
    goTo(current - 1);
  });

  nextBtn.addEventListener("click", function () {
    goTo(current + 1);
  });

  carousel.addEventListener("keydown", function (e) {
    if (lightbox && !lightbox.hidden) return;
    if (e.key === "ArrowLeft") {
      goTo(current - 1);
    } else if (e.key === "ArrowRight") {
      goTo(current + 1);
    }
  });

  slides.forEach(function (slide) {
    slide.addEventListener("click", openLightbox);
  });

  if (lightbox) {
    lightbox.addEventListener("click", function (e) {
      if (e.target === lightbox) closeLightbox();
    });
  }

  if (lightboxClose) {
    lightboxClose.addEventListener("click", closeLightbox);
  }

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && lightbox && !lightbox.hidden) {
      closeLightbox();
    }
  });
})();
