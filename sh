///shearing
///3rd
#include<windows.h>
#include<iostream>
#include<GL/glut.h>
#include<math.h>
using namespace std;

#define SCREEN_HEIGHT 480

int count = 0;
int countPoints = 0;
int countRect = 0;
int countCircle = 0;
string shape="";

struct Point
{
    GLint x;
    GLint y;
};
Point lowerLeft = {0,0};
Point upperRight = {100,100};

struct GLColor
{
    GLfloat red;
    GLfloat green;
    GLfloat blue;
};


void init()
{
    glClearColor(0.0f, 0.0f, 0.0f, 0);
    glPointSize(1.0f);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, 640.0, 0.0, 480.0);
}

void display(void) {
    glColor3f(0.4,0.8,0);
    glBegin(GL_LINES);
        glVertex2f(320,0);
        glVertex2f(320,480);
        glVertex2f(0,240);
        glVertex2f(640,240);
    glEnd();

    glColor3f(0.4,0,0.8);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glBegin(GL_QUADS);
        glVertex2f(lowerLeft.x+320,lowerLeft.y+240);
        glVertex2f(upperRight.x+320,lowerLeft.y+240);
        glVertex2f(upperRight.x+320,upperRight.y+240);
        glVertex2f(lowerLeft.x+320,upperRight.y+240);
    glEnd();
    glFlush();
}

void draw(Point lowerLeft,Point lowerRight,Point upperRight,Point upperLeft)
{
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glBegin(GL_QUADS);
        glVertex2f(lowerLeft.x+320,lowerLeft.y+240);
        glVertex2f(lowerRight.x+320,lowerRight.y+240);
        glVertex2f(upperRight.x+320,upperRight.y+240);
        glVertex2f(upperLeft.x+320,upperLeft.y+240);
    glEnd();
    glFlush();

}

void shearing()
{
    float shearingX=0.5,shearingY=0.5,refY=-1,refX=-1;
    Point p1,p2,p3,p4;
    p1.x=lowerLeft.x+shearingX*(lowerLeft.y-refY);
    p1.y=lowerLeft.y;
    p2.x=upperRight.x+shearingX*(lowerLeft.y-refY);
    p2.y=lowerLeft.y;
    p3.x=upperRight.x+shearingX*(upperRight.y-refY);
    p3.y=upperRight.y;
    p4.x=lowerLeft.x+shearingX*(upperRight.y-refY);
    p4.y=upperRight.y;
    glColor3f(0,0,1);
    draw(p1,p2,p3,p4);

    p1.x=lowerLeft.x;
    p1.y=lowerLeft.y + shearingY*(lowerLeft.x-refX);
    p2.x=upperRight.x;
    p2.y=lowerLeft.y + shearingY*(upperRight.x-refX);
    p3.x=upperRight.x;
    p3.y=upperRight.y + shearingY*(upperRight.x-refX);
    p4.x=lowerLeft.x;
    p4.y=upperRight.y + shearingY*(lowerLeft.x-refX);
    glColor3f(1,1,0);
    draw(p1,p2,p3,p4);
}

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE|GLUT_RGB);
    glutInitWindowPosition(200, 200);
    glutInitWindowSize(640, 480);
    glutCreateWindow("OpenGL");
    init();

    glutDisplayFunc(display);
    shearing();
    glutMainLoop();

    return 0;
}
