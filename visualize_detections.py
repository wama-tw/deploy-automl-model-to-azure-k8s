import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import matplotlib.patches as patches
from PIL import Image
import numpy as np
import json
import os

dataset_dir = "./sample_request_data"
sample_image = os.path.join(dataset_dir, "56.jpg")

IMAGE_SIZE = (18, 12)
plt.figure(figsize=IMAGE_SIZE)
img_np = mpimg.imread(sample_image)
img = Image.fromarray(img_np.astype("uint8"), "RGB")
x, y = img.size

fig, ax = plt.subplots(1, figsize=(15, 15))
# Display the image
ax.imshow(img_np)

# draw box and label for each detection
with open('sample_response.json') as resp:
  detections = resp.read()
detections = json.loads(detections)
print(detections)

for detect in detections[0]["boxes"]:
  label = detect["label"]
  box = detect["box"]
  conf_score = detect["score"]
  if conf_score > 0.7:
    ymin, xmin, ymax, xmax = (
      box["topY"],
      box["topX"],
      box["bottomY"],
      box["bottomX"],
    )
    topleft_x, topleft_y = x * xmin, y * ymin
    width, height = x * (xmax - xmin), y * (ymax - ymin)
    print(
      f"{detect['label']}: [{round(topleft_x, 3)}, {round(topleft_y, 3)}, "
      f"{round(width, 3)}, {round(height, 3)}], {round(conf_score, 3)}"
    )

    color = np.random.rand(3)  #'red'
    rect = patches.Rectangle(
      (topleft_x, topleft_y),
      width,
      height,
      linewidth=3,
      edgecolor=color,
      facecolor="none",
    )
    ax.add_patch(rect)
    plt.text(topleft_x, topleft_y - 10, label, color=color, fontsize=20)
# plt.show()
plt.savefig('detection.png')