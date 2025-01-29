#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>

GLuint width = 600, height = 600;
int kut = 0;

typedef struct _Ociste {
    GLdouble	x;
    GLdouble	y;
    GLdouble	z;
} Ociste;

Ociste	ociste = { 0.0f, 0.0f, 2.0f };

void myDisplay();
void myReshape(int width, int height);
void myDrawSquare();
void myRenderScene();
void idle();
void myKeyboard(unsigned char theKey, int mouseX, int mouseY);

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE);
    glutInitWindowSize(width, height);
    glutInitWindowPosition(0, 0);
    glutCreateWindow("Primjer animacije");
    glutDisplayFunc(myDisplay);
    glutReshapeFunc(myReshape);
    glutIdleFunc(idle);
    glutKeyboardFunc(myKeyboard);
    printf("Tipka: a/d - pomicanje ocista po x os +/-\n");
    printf("Tipka: w/s - pomicanje ocista po y os +/-\n");
    printf("Tipka: r - pocetno stanje\n");
    printf("esc: izlaz iz programa\n");

    glutMainLoop();
    return 0;
}

void myDisplay()
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    myRenderScene();
    glutSwapBuffers();
}

void myReshape(int w, int h)
{
    width = w; height = h;
    //glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1, 1, -1, 1, 1, 5);
    //glFrustum(-1, 1, -1, 1, 1, 5);
    glViewport(0, 0, (GLsizei)width, (GLsizei)height);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(ociste.x, ociste.y, ociste.z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);	// ociste x,y,z; glediste x,y,z; up vektor x,y,z
    }

void myDrawSquare()
{
    glBegin(GL_QUADS);
    glVertex3f(-0.4f, -0.4f, 0.0f);
    glVertex3f(0.4f, -0.4f, 0.0f);
    glVertex3f(0.4f, 0.4f, 0.0f);
    glVertex3f(-0.4f, 0.4f, 0.0f);
    glEnd();
}

void myRenderScene()
{
    glColor3f(1.0f, 0.0f, 0.0f);
    glPushMatrix();
    glTranslatef(0.5f, 0.0f, 0.0f);
    glScalef(1.0f, 1.0f, 1.0f);
    glRotatef((float)kut, 0.0f, 0.0f, 1.0f);
    myDrawSquare();
    glPopMatrix();
    glPushMatrix();
    glColor3f(0.0f, 1.0f, 0.0f);
    glTranslatef(-0.5f, 0.0f, 0.0f);
    glScalef(1.0f, 1.0f, 1.0f);
    glRotatef(-(float)kut, 0.0f, 0.0f, 1.0f);
    myDrawSquare();
    glPopMatrix();
}

void myKeyboard(unsigned char theKey, int mouseX, int mouseY)
{
    switch (theKey)
    {
    case 'a': ociste.x = ociste.x+0.2f;
        break;
    case 'd': ociste.x = ociste.x-0.2f;
        break;
    case 'w': ociste.y = ociste.y + 0.2f;
        break;
    case 's': ociste.y = ociste.y - 0.2f;
        break;
    case 'r': ociste.x = 0.0; ociste.y = 0.0;
        break;
    case 27:  exit(0);
        break;
    }
    
    myReshape(width, height);
    glutPostRedisplay();
}

void idle() {
    kut++;
    if (kut >= 360) kut = 0;
    glutPostRedisplay();
}

