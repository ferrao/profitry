defmodule ProfitryWeb.IconComponents do
  use Phoenix.Component

  def profitry_icon(assigns) do
    ~H"""
    <svg
      width="48"
      height="48"
      viewBox="0 0 48 48"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      xmlns="http://www.w3.org/2000/svg"
      class="text-gray-800"
    >
      <!-- Outer square boundary -->
      <rect x="4" y="4" width="40" height="40" rx="4" ry="4" />
      <!-- Upward trending line chart -->
      <path d="M12 32L20 24L28 28L36 16" />
      <!-- Axes for the payoff diagram -->
      <!-- Vertical axis -->
      <path d="M12 36 L12 12" />
      <!-- Horizontal axis -->
      <path d="M12 36 L36 36" />
      <!-- Call option payoff line: flat until strike, then upward -->
      <!-- Imagine the strike price at around x=24 -->
      <!-- Flat portion: from x=12 to x=24 at y=36 (no profit zone) -->
      <path d="M12 36 L24 36" />
      <!-- Upward portion: from x=24 to x=36 (increasing profit zone) -->
      <path d="M24 36 L36 24" />
    </svg>
    """
  end
end
