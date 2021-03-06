// D for DATA

interface EventHandler {
   public boolean handleEvent(Event e);
}

class MyPanel extends Panel {
   int XSIZE = 1000;
   int YSIZE = 600;

   public int xsize() const { return XSIZE }
   public int ysize() const { return YSIZE }

   public MyPanel() {
	  Panel();
	  eventHandler_ = null;
	  frame_  = new Frame("Bouncy");
	  frame_.add("Center", this);
	  frame_.resize(xsize(), ysize());
	  frame_.setVisible(true);
	  drawRect(0, 0, xsize(), ysize());
	  repaint()
   }

   public boolean handleEvent(Event event) {
	  boolean retval = true;
	  if (event.id == Event.MOUSE_MOVE) {
		 if (eventHandler_ != null) {
			retval = eventHandler_.handleEvent(event)
		 }
	  }
	  return retval
   }

   public void setEventHandler(EventHandler eh) {
	  eventHandler_ = eh
   }

   public Frame frame() { return frame_ }

   private Frame frame_;
   private EventHandler eventHandler_
}

class BallObject extends Point {
   public BallObject(int x, int y) {
	  Point(x, y);
	  velocity_ = new Point(7, 7)
   }
   public int radius() const { return RADIUS }
   public Point velocity() const { return velocity_ }
   public void setVelocity(Point velocity) { velocity_=velocity }
   Point velocity_;
   private int RADIUS = 15
}

// C for CONTEXT

context Arena implements EventHandler {
   public Arena() {
	  MyPanel panel = new MyPanel();
	  THE_PANEL = panel;
	  THE_PANEL.clear();
	  BALL = new BallObject(50, 50);
	  PADDLE = new Point(450, 560);
	  panel.setEventHandler(this)
   }
   public void run() {
	  do {
		 THE_PANEL.clear();
		 PADDLE.draw();
		 BALL.draw()
		 BALL.velocityAdjust();
		 BALL.step();
		 THE_PANEL.flush();
		 Thread.sleep(20)
	  } while (true)
   }

// I for  INTERACTON
   role THE_PANEL {
	  public void drawCircle(int x, int y, int r) {
		 fillOval(x+r, y+r, r, r)
	  }
	  public void drawPADDLE(int xs, int ys, int h, int w) {
		 drawRect(xs, ys, h, w)
	  }
	  public int maxX() const { return xsize() }
	  public int maxY() const { return ysize() }
	  public void flush() { repaint(); }
	  public void clear() {
		 setColor(new Color(227, 221, 240));
		 fillRect(0, 0, maxX()-1, maxY()-1)
	  }
   } requires {
	  void fillOval(int x, int y, int h, int w);
	  void drawRect(int x, int y, int h, int w);
	  void fillRect(int x, int y, int h, int w);
	  int xsize() const;
	  int ysize() const;
	  void setColor(Color color);
	  void repaint();
   }
   role PADDLE {
	  public int thickness() const { return 10 }
	  public int width() const { return 100 }
	  public void draw() {
		 THE_PANEL.setColor(new Color(32, 170, 64));
		 THE_PANEL.drawPADDLE(getX() - (width() / 2), getY(),
							 width(), thickness())
	  }
	  public void erase() {
		 THE_PANEL.setColor(new Color(239, 237, 239));
		 THE_PANEL.drawPADDLE(getX() - (width() / 2), getY(),
							 width(), thickness())
	  }
	  public void moveTo(Point p) { setXY(p.getX(), getY()) }
	  public boolean contains(int x) const {
		 return ((x > (getX() - (width() / 2))) &&
				(x < (getX() + (width() / 2))))
	  }
	  public int vertical() const { return getY() - thickness() }
   } requires {
	  void setXY(int x, int y);
	  int getX() const;
	  int getY() const
   }
   role BALL {
	  public void erase() {
		 THE_PANEL.setColor(new Color(239, 237, 239));
		 THE_PANEL.drawCircle(getX(), getY(), radius())
	  }
	  public void draw() {
		 THE_PANEL.setColor(Color.blue);
		 THE_PANEL.drawCircle(getX(), getY(), radius())
	  }
	  public void step() { setXY(getX() + velocity().getX, getY() + velocity().getY) }
	  private boolean bouncingOffOfPADDLE() {
		 return if (getY() + (radius() * 2) > PADDLE.vertical)
				   PADDLE.contains(getX() + radius())
				else false
	  }
	  public void velocityAdjust() {
		 int xv = velocity().getX, yv = velocity().getY;
		 xv = if (velocity().getX() > 0) {
			if (getX() + (radius() * 2) >= THE_PANEL.maxX) -xv else xv
		 } else if (getX() + radius() <= 0) -xv else xv;

		 yv = if (velocity().getY() > 0) {
			if (bouncingOffOfPADDLE()) -yv else yv
		 } else if (getY() + (radius() * 2) <= 0) -yv else yv

		 setVelocity(new Point(xv, yv))
	  }
   } requires {
	  void setXY(int x, int y);
	  int getX() const;
	  int getY() const;
	  Point velocity();
	  void setVelocity(Point velocity);
	  int radius()
   }

   private boolean handleEvent(Event e) {
	  if (e.id == Event.MOUSE_MOVE) {
		 PADDLE.moveTo(new Point(e.x, e.y))
	  }
	  return true
   }
}

new Arena().run()
