Question 1:
Widgets usually expose controllers to allow the developer granular control
over certain features. You’ve already used one when you implemented
TextFields in the previous assignment (Remember?).
Read this thread and then go to snapping_sheet’s documentation.
Answer: What class is used to implement the controller pattern in this library?
What features does it allow the developer to control?

Answer 1:
The SnappingSheetController class is used to implement the controller pattern in the library . It allows the developer to control the snap positions of the snapping sheet, it also has the ability to change the snap position by snapToPosition.


Question 2:
The library allows the bottom sheet to snap into position with various different
animations. What parameter controls this behavior? 

Answer 2:
The parameter that allows this behavior is snappingCurve and it comes with other auxiliary parameters such as positionPixel, snappingDuration, positionFactor, etc..


Question 3:
[This question does not directly relate to the previous ones] Read the
documentation of InkWell and GestureDetector. Name one advantage of
InkWell over the latter and one advantage of GestureDetector over the first

Answer 3:
GestureDetector's advantage over Inkwell: It offers a more broad set of gesture events (like dragging), and that it doesn't need to have a material ancestor.

Inkwell's advantage over GestureDetector: The advantage is that Inkwell is a rectangle area of Material that responds to ink splashes, so it has effects such as ripple effect tap.
