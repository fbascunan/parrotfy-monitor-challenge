// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "vue"

import { createApp } from "vue"

document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("vue-app")
  if (el) {
    createApp({
      data() {
        return { message: "Hello from Vue 3!" }
      },
      template: `<div class='p-4 bg-green-100 rounded'>{{ message }}</div>`
    }).mount(el)
  }
})
import "./channels"
