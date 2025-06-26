// Loading Spinner Component
export default {
  name: 'LoadingSpinner',
  props: {
    size: {
      type: String,
      default: 'medium', // small, medium, large
      validator: value => ['small', 'medium', 'large'].includes(value)
    },
    color: {
      type: String,
      default: 'blue', // blue, green, red, gray
      validator: value => ['blue', 'green', 'red', 'gray'].includes(value)
    },
    text: {
      type: String,
      default: 'Loading...'
    },
    overlay: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    sizeClasses() {
      const sizes = {
        small: 'w-4 h-4',
        medium: 'w-8 h-8',
        large: 'w-12 h-12'
      }
      return sizes[this.size]
    },
    colorClasses() {
      const colors = {
        blue: 'text-blue-600',
        green: 'text-green-600',
        red: 'text-red-600',
        gray: 'text-gray-600'
      }
      return colors[this.color]
    }
  },
  template: `
    <div :class="overlay ? 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50' : 'flex items-center justify-center'">
      <div class="text-center">
        <div :class="['animate-spin rounded-full border-2 border-gray-300 border-t-current', sizeClasses, colorClasses]"></div>
        <p v-if="text" class="mt-2 text-sm text-gray-600">{{ text }}</p>
      </div>
    </div>
  `
} 