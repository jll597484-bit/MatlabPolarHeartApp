import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider
from matplotlib.animation import FuncAnimation

class PolarHeartApp:
    def __init__(self):
        self.fig, self.ax = plt.subplots(subplot_kw={"projection": "polar"})
        self.ax.set_title("极坐标心形线: r = a(1 - sin(θ))")
        self.ax.set_theta_zero_location("N") # Set 0 degrees to the top
        self.ax.set_theta_direction(-1)     # Clockwise direction
        
        # Initial 'a' value
        self.a_initial = 1.0
        self.a = self.a_initial
        
        # Theta values for the heart curve
        self.theta_full = np.linspace(0, 2 * np.pi, 500)
        self.r_full = self.a * (1 - np.sin(self.theta_full))
        
        # Initial plot (empty line for animation)
        self.line, = self.ax.plot([], [], color='red', linewidth=2)
        
        # Slider for 'a'
        axcolor = 'lightgoldenrodyellow'
        ax_a = plt.axes([0.25, 0.05, 0.65, 0.03], facecolor=axcolor)
        self.slider_a = Slider(ax_a, 'a', 0.1, 2.0, valinit=self.a_initial, valstep=0.05)
        self.slider_a.on_changed(self.update_a)
        
        # Animation setup
        self.current_idx = 0
        self.animation = FuncAnimation(self.fig, self.animate, frames=len(self.theta_full) + 1, 
                                       interval=10, blit=True, repeat=False)
        
        plt.show()

    def update_a(self, val):
        self.a = self.slider_a.val
        self.r_full = self.a * (1 - np.sin(self.theta_full))
        
        # Restart animation with new 'a' value
        self.animation.event_source.stop()
        self.current_idx = 0
        self.animation = FuncAnimation(self.fig, self.animate, frames=len(self.theta_full) + 1, 
                                       interval=10, blit=True, repeat=False)
        self.animation.event_source.start()

    def animate(self, i):
        if i > len(self.theta_full):
            return self.line,
        
        self.current_idx = i
        theta_to_plot = self.theta_full[:self.current_idx]
        r_to_plot = self.r_full[:self.current_idx]
        
        self.line.set_data(theta_to_plot, r_to_plot)
        return self.line,

if __name__ == '__main__':
    app = PolarHeartApp()
